package handler

import (
	"regexp"
	"strings"
)

var (
	archRe    = regexp.MustCompile(`(aarch64|armv6|armv7|armv8|arm64|arm|386|amd64|32|64|mips)`)
	fileExtRe = regexp.MustCompile(`(\.[a-z][a-z0-9]+)+$`)
	posixOSRe = regexp.MustCompile(`(darwin|linux|(net|free|open)bsd|mac|osx|windows|win|solaris)`)
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
	if a == "64" || a == "" {
		a = "amd64"
	} else if a == "32" {
		a = "386"
	} else if a == "armv8" || a == "aarch64" {
		a = "arm64"
	} else if a == "armv6" || a == "armv7" {
		a = "arm"
	}
	return a
}

func getFileExt(s string) string {
	return fileExtRe.FindString(s)
}
