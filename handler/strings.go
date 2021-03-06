package handler

import (
	"regexp"
	"strings"
)

var (
	archRe    = regexp.MustCompile(`(aarch64|armv6|armv7|armv8|arm64|arm|amd32|x32|x86(-|_)?32|386|amd64|x64|x86(-|_)?64|mips64le|mips64|mipsle|mips|ppc64le|ppc64|ppc|ppcle|s390x)`)
	fileExtRe = regexp.MustCompile(`(\.[a-z][a-z0-9]+)+$`)
	posixOSRe = regexp.MustCompile(`(android|darwin|linux|(net|free|open)bsd|mac|osx|windows|win|solaris)`)
)

func getOS(s string) string {
	s = strings.ToLower(s)
	o := posixOSRe.FindString(s)
	if o == "mac" || o == "osx" {
		o = "darwin"
	}
	if o == "win" {
		o = "windows"
	}
	return o
}

func getArch(s string) string {
	s = strings.ToLower(s)
	a := archRe.FindString(s)
	if a == "x64" || a == "x86_64" {
		a = "amd64"
	} else if a == "x32" || a == "x86" || a == "x86_32" || a == "amd32" {
		a = "386"
	} else if a == "aarch64" || a == "armv8" {
		a = "arm64"
	}
	return a
}

func getFileExt(s string) string {
	return fileExtRe.FindString(s)
}
