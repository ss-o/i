package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/jpillora/opts"
	"github.com/jpillora/requestlog"
	"github.com/ss-o/i/handler"
)

var version = "0.0.0-src" // ldflagsVersion is set by the build script

func main() {
	c := handler.DefaultConfig
	opts.New(&c).Repo("github.com/ss-o/i").Version(version).Parse()
	log.Printf("default user is '%s'", c.User)
	if c.Token == "" && os.Getenv("GH_TOKEN") != "" {
		c.Token = os.Getenv("GH_TOKEN") // GH_TOKEN was renamed
	}
	if c.Token != "" {
		log.Printf("github token will be used for requests to api.github.com")
	}
	if c.ForceUser != "" {
		log.Printf("locked user to '%s'", c.ForceUser)
	}
	if c.ForceRepo != "" {
		log.Printf("locked repo to '%s'", c.ForceRepo)
	}
	addr := fmt.Sprintf("%s:%d", c.Host, c.Port)
	l, err := net.Listen("tcp4", addr)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("listening on %s", addr)
	h := &handler.Handler{Config: c}
	lh := requestlog.WrapWith(h, requestlog.Options{
		TrustProxy: true, // assume will be run behind a reverse proxy
		Filter: func(r *http.Request, code int, duration time.Duration, size int64) bool {
			return r.URL.Path != "/health"
		},
	})
	if err := http.Serve(l, lh); err != nil {
		log.Fatal(err)
	}
	log.Print("exiting")
}
