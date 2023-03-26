package handler

// Path: handler/config.go
// Compare this snippet from handler/search.go:

// Configuration for the server.
type Config struct {
	Host      string `opts:"help=host, env=HTTP_HOST"`
	Port      int    `opts:"help=port, env"`
	User      string `opts:"help=default user for URL requests, env"`
	Token     string `opts:"help=token for GitHub API, env=GITHUB_TOKEN"`
	ForceUser string `opts:"help=forcefully use single owner, env=FORCE_USER"`
	ForceRepo string `opts:"help=forcefully use a single repository, env=FORCE_REPO"`
}

var DefaultConfig = Config{
	Port: 3000,
	User: "ss-o",
}
