package handler

// Config installer handler
type Config struct {
	Host      string `opts:"help=host, env=HTTP_HOST"`
	Port      int    `opts:"help=port, env"`
	User      string `opts:"help=default user when not provided in URL, env"`
	Token     string `opts:"help=github api token, env=GITHUB_TOKEN"`
	ForceUser string `opts:"help=lock installer to a single user, env=FORCE_USER"`
	ForceRepo string `opts:"help=lock installer to a single repo, env=FORCE_REPO"`
}

var DefaultConfig = Config{
	Port: 3000,
	User: "ss-o",
}
