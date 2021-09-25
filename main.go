package main

import (
	"log"
	"net/http"
	"strconv"

	"github.com/jpillora/opts"
	"github.com/ss-o/i/handler"
)

var version = "1.0.3"

func main() {
	c := handler.DefaultConfig
	opts.New(&c).Repo("github.com/ss-o/i").Version(version).Parse()
	log.Printf("Default user is '%s', GH token set: %v, listening on %d...", c.User, c.Token != "", c.Port)
	h := &handler.Handler{Config: c}
	if err := http.ListenAndServe(":"+strconv.Itoa(c.Port), h); err != nil {
		log.Fatal(err)
	}
}
