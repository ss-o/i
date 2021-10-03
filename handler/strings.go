package handler

import (
	"regexp"
	"strings"
)

var (
	archRe    = regexp.MustCompile(`(arm|arm64|armv8|aarch64|386|amd64|32|64|mips|mips64)`)
	fileExtRe = regexp.MustCompile(`(\.[a-z][a-z0-9]+)+$`)
	posixOSRe = regexp.MustCompile(`(darwin|linux|(net|free|open)bsd|mac|osx|windows|win)`)


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
	}
	return a
}

func getFileExt(s string) string {
	return fileExtRe.FindString(s)
}
