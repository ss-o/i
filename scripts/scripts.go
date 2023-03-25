package scripts

import _ "embed"

//go:embed install.txt
var Text []byte

//go:embed install.sh
var Shell []byte

//go:embed install.rb
var Homebrew []byte
