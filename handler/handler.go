package handler

import (
	"bytes"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"regexp"
	"strings"
	"sync"
	"text/template"
	"time"

	"github.com/ss-o/i/scripts"
)

const (
	cacheTTL = time.Hour
)

var (
	isTermRe     = regexp.MustCompile(`(?i)^(curl|wget)\/`)
	isHomebrewRe = regexp.MustCompile(`(?i)^homebrew`)
	errMsgRe     = regexp.MustCompile(`[^A-Za-z0-9\ :\/\.]`)
	errNotFound  = errors.New("not found")
)

type Query struct {
	User, Program, AsProgram, Release string
	MoveToPath, Google, Insecure      bool
}

type Result struct {
	Query
	Timestamp time.Time
	Assets    Assets
	M1Asset   bool
}

func (q Query) cacheKey() string {
	hw := sha256.New()
	jw := json.NewEncoder(hw)
	if err := jw.Encode(q); err != nil {
		panic(err)
	}
	return base64.StdEncoding.EncodeToString(hw.Sum(nil))
}

// Handler serves install scripts using Github releases
type Handler struct {
	Config
	cacheMut sync.Mutex
	cache    map[string]Result
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/health" {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		w.Write([]byte("{\"status\": \"ok\"}")) //nolint:errcheck
		w.WriteHeader(http.StatusOK)
		return
	} else if r.URL.Path == "/robots.txt" {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.Header().Set("Cache-Control", "no-cache")
		w.Write([]byte("User-agent: *\nDisallow: /")) //nolint:errcheck
		w.WriteHeader(http.StatusOK)
		return
	} else if r.URL.Path == "/" {
		http.Redirect(w, r, "https://github.com/ss-o/i", http.StatusMovedPermanently)
		return
	}
	// calculate response type
	ext := ""
	script := ""
	qtype := r.URL.Query().Get("type")
	if qtype == "" {
		ua := r.Header.Get("User-Agent")
		switch {
		case isTermRe.MatchString(ua):
			qtype = "script"
		case isHomebrewRe.MatchString(ua):
			qtype = "ruby"
		default:
			qtype = "text"
		}
	}
	// type specific error response
	showError := func(msg string, code int) {
		// prevent shell injection
		cleaned := errMsgRe.ReplaceAllString(msg, "")
		if qtype == "script" {
			cleaned = fmt.Sprintf("echo '%s'", cleaned)
		}
		http.Error(w, cleaned, http.StatusInternalServerError)
	}
	switch qtype {
	case "script":
		w.Header().Set("Content-Type", "text/x-shellscript; charset=utf-8")
		ext = "sh"
		script = string(scripts.Shell)
	case "homebrew", "ruby":
		w.Header().Set("Content-Type", "text/x-ruby; charset=utf-8")
		ext = "rb"
		script = string(scripts.Homebrew)
	case "text":
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		ext = "txt"
		script = string(scripts.Text)
	default:
		showError("Unknown type", http.StatusInternalServerError)
		return
	}

	// parse query
	q := Query{
		User:      "",
		Program:   "",
		Release:   "",
		Insecure:  r.URL.Query().Get("insecure") == "1",
		AsProgram: r.URL.Query().Get("as"),
	}
	// set query from route
	path := strings.TrimPrefix(r.URL.Path, "/")
	// move to path with !
	if strings.HasSuffix(path, "!") {
		q.MoveToPath = true
		path = strings.TrimRight(path, "!")
	}
	var rest string
	q.User, rest = splitHalf(path, "/")
	q.Program, q.Release = splitHalf(rest, "@")
	// no program? treat first part as program, use default user
	if q.Program == "" {
		q.Program = q.User
		q.User = h.Config.User
		q.Google = true
	}
	// micro > nano!
	if q.User == "" && q.Program == "micro" {
		q.User = "zyedidia"
	}
	// force user/repo
	if h.Config.ForceUser != "" {
		q.User = h.Config.ForceUser
	}
	if h.Config.ForceRepo != "" {
		q.Program = h.Config.ForceRepo
	}

	// validate query
	valid := q.User != ""
	if !valid && path == "" {
		http.Redirect(w, r, "https://github.com/ss-o/i", http.StatusMovedPermanently)
		return
	}
	if !valid {
		log.Printf("invalid path: query: %#v", q)
		showError("Invalid path", http.StatusBadRequest)
		return
	}
	// fetch assets
	result, err := h.execute(q)
	if err != nil {
		showError(err.Error(), http.StatusBadGateway)
		return
	}
	// load template
	t, err := template.New("i-get").Parse(script)
	if err != nil {
		showError("Error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	// execute template
	buff := bytes.Buffer{}
	if err := t.Execute(&buff, result); err != nil {
		showError("Template error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	log.Printf("serving script %s/%s@%s (%s)", q.User, q.Program, q.Release, ext)
	// ready
	w.Write(buff.Bytes()) //nolint:errcheck
}

type Asset struct {
	Name, OS, Arch, URL, Type, SHA256 string
}

func (a Asset) Key() string {
	return a.OS + "/" + a.Arch
}

func (a Asset) Is32Bit() bool {
	return a.Arch == "386"
}

func (a Asset) IsMac() bool {
	return a.OS == "darwin"
}

func (a Asset) IsMacM1() bool {
	return a.IsMac() && a.Arch == "arm64"
}

type Assets []Asset

func (as Assets) HasM1() bool {
	//detect if we have a native m1 asset
	for _, a := range as {
		if a.IsMacM1() {
			return true
		}
	}
	return false
}

func (h *Handler) get(url string, v interface{}) error {
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Add("Accept", "application/vnd.github+json")
	req.Header.Add("X-GitHub-Api-Version", "2022-11-28")
	req.Header.Add("Content-Type", "application/json")
	if h.Config.Token != "" {
		var bearer = "Bearer " + h.Config.Token
		req.Header.Set("Authorization", bearer)
	}
	//resp, err := http.Get(url)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %s: %s", url, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode == 400 {
		return fmt.Errorf("GitHub API version expired, please update")
	}
	if resp.StatusCode == 404 {
		return fmt.Errorf("%w: url %s", errNotFound, url)
	}
	if resp.StatusCode != 200 {
		b, _ := io.ReadAll(resp.Body)
		return errors.New(http.StatusText(resp.StatusCode) + " " + string(b))
	}
	if err := json.NewDecoder(resp.Body).Decode(v); err != nil {
		return fmt.Errorf("download failed: %s: %s", url, err)
	}
	return nil
}
