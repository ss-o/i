package handler

import (
	"bufio"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"
)

func (h *Handler) execute(q Query) (Result, error) {
	// load from cache
	key := q.cacheKey()
	h.cacheMut.Lock()
	if h.cache == nil {
		h.cache = map[string]Result{}
	}
	cached, ok := h.cache[key]
	h.cacheMut.Unlock()
	// cache hit
	if ok && time.Since(cached.Timestamp) < cacheTTL {
		return cached, nil
	}
	// do real operation
	ts := time.Now()
	release, assets, err := h.getAssetsNoCache(q)
	if err == nil {
		// google not used
		q.Google = false
	} else if errors.Is(err, errNotFound) && q.Google {
		// use google to auto-detect user...
		user, program, gerr := searchGoogle(q.Program)
		if gerr != nil {
			log.Printf("google search failed: %s", gerr)
		} else {
			log.Printf("google search found: %s/%s", user, program)
			if program != q.Program {
				log.Printf("program mismatch: got %s: expected %s", q.Program, program)
			}
			q.Program = program
			q.User = user
			// retry assets...
			release, assets, err = h.getAssetsNoCache(q)
		}
	}
	// asset fetch failed, don't cache
	if err != nil {
		return Result{}, err
	}
	// success
	if q.Release == "" && release != "" {
		log.Printf("detected release: %s", release)
		q.Release = release
	}
	result := Result{
		Timestamp: ts,
		Query:     q,
		Assets:    assets,
		M1Asset:   assets.HasM1(),
	}
	// success store results
	h.cacheMut.Lock()
	h.cache[key] = result
	h.cacheMut.Unlock()
	return result, nil
}

func (h *Handler) getAssetsNoCache(q Query) (string, Assets, error) {
	user := q.User
	repo := q.Program
	release := q.Release
	//not cached - ask github
	log.Printf("fetching asset info for %s/%s@%s", user, repo, release)
	url := fmt.Sprintf("https://api.github.com/repos/%s/%s/releases", user, repo)
	ghas := ghAssets{}
	if release == "" {
		url += "/latest"
		ghr := ghRelease{}
		if err := h.get(url, &ghr); err != nil {
			return release, nil, err
		}
		release = ghr.TagName // discovered
		ghas = ghr.Assets
	} else {
		ghrs := []ghRelease{}
		if err := h.get(url, &ghrs); err != nil {
			return release, nil, err
		}
		found := false
		for _, ghr := range ghrs {
			if ghr.TagName == release {
				found = true
				if err := h.get(ghr.AssetsURL, &ghas); err != nil {
					return release, nil, err
				}
				ghas = ghr.Assets
				break
			}
		}
		if !found {
			return release, nil, fmt.Errorf("release tag '%s' not found", release)
		}
	}
	if len(ghas) == 0 {
		return release, nil, errors.New("no assets found")
	}
	sumIndex, _ := ghas.getSumIndex()
	if l := len(sumIndex); l > 0 {
		log.Printf("fetched %d asset shasums", l)
	}
	assets := Assets{}
	index := map[string]bool{}
	for _, ga := range ghas {
		url := ga.BrowserDownloadURL
		//only binary containers are supported
		fext := getFileExt(url)
		if fext == "" && ga.Size > 1024*1024 {
			fext = ".bin" // +1MB binary
		}
		if fext != ".bin" && fext != ".zip" && fext != ".gz" && fext != ".tar.gz" && fext != ".tgz" && fext != ".7z" && fext != ".xz" && fext != ".bz2" && fext != ".tar.bz2" {
			log.Printf("fetched asset has unsupported file type: %s (ext '%s')", ga.Name, fext)
			continue
		}
		// skip duplicates
		if _, ok := index[url]; ok {
			log.Printf("fetched asset is a duplicate: %s", ga.Name)
			continue
		}
		index[url] = true

		// match
		os := getOS(ga.Name)
		arch := getArch(ga.Name)

		if os == "windows" {
			log.Printf("fetched asset is for windows: %s", ga.Name)
			continue
		}
		// log unknown os
		if os == "" {
			log.Printf("fetched asset has unknown os: %s", ga.Name)
			continue
		}
		log.Printf("fetched asset: %s", ga.Name)
		asset := Asset{
			OS:     os,
			Arch:   arch,
			Name:   ga.Name,
			URL:    url,
			Type:   fext,
			SHA256: sumIndex[ga.Name],
		}
		// there can only be 1 file for each OS/Arch
		if index[asset.Key()] {
			continue
		}
		index[asset.Key()] = true
		// include
		assets = append(assets, asset)
	}
	if len(assets) == 0 {
		return release, nil, errors.New("no downloads found for this release")
	}
	return release, assets, nil
}

type ghAssets []ghAsset

func (as ghAssets) getSumIndex() (map[string]string, error) {
	url := ""
	for _, ga := range as {
		// check if checksum file
		if ga.IsChecksumFile() {
			url = ga.BrowserDownloadURL
			break
		}
	}
	if url == "" {
		return nil, errors.New("no sum file found")
	}
	resp, err := http.DefaultClient.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	// take each line and insert into the index
	index := map[string]string{}
	s := bufio.NewScanner(resp.Body)
	for s.Scan() {
		fs := strings.Fields(s.Text())
		if len(fs) != 2 {
			continue
		}
		index[fs[1]] = fs[0]
	}
	if err := s.Err(); err != nil {
		return nil, err
	}
	return index, nil
}

type ghAsset struct {
	BrowserDownloadURL string `json:"browser_download_url"`
	ContentType        string `json:"content_type"`
	CreatedAt          string `json:"created_at"`
	DownloadCount      int    `json:"download_count"`
	ID                 int    `json:"id"`
	Label              string `json:"label"`
	Name               string `json:"name"`
	Size               int    `json:"size"`
	State              string `json:"state"`
	UpdatedAt          string `json:"updated_at"`
	Uploader           struct {
		ID    int    `json:"id"`
		Login string `json:"login"`
	} `json:"uploader"`
	URL string `json:"url"`
}

func (g ghAsset) IsChecksumFile() bool {
	return checksumRe.MatchString(strings.ToLower(g.Name)) && g.Size < 64*1024 //maximum file size 64KB
}

type ghRelease struct {
	Assets    []ghAsset `json:"assets"`
	AssetsURL string    `json:"assets_url"`
	Author    struct {
		ID    int    `json:"id"`
		Login string `json:"login"`
	} `json:"author"`
	Body            string      `json:"body"`
	CreatedAt       string      `json:"created_at"`
	Draft           bool        `json:"draft"`
	HTMLURL         string      `json:"html_url"`
	ID              int         `json:"id"`
	Name            interface{} `json:"name"`
	Prerelease      bool        `json:"prerelease"`
	PublishedAt     string      `json:"published_at"`
	TagName         string      `json:"tag_name"`
	TarballURL      string      `json:"tarball_url"`
	TargetCommitish string      `json:"target_commitish"`
	UploadURL       string      `json:"upload_url"`
	URL             string      `json:"url"`
	ZipballURL      string      `json:"zipball_url"`
}
