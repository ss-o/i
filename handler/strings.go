package handler

import (
	"regexp"
	"strings"
)

var (
	archRe    = regexp.MustCompile(`(armv8|aarch64|arm64|arm|386|amd64|x32|x64|mips)`)
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
	if a == "x64" || a == "" {
		a = "amd64"
	} else if a == "x32" {
		a = "386"
	} else if a == "armv8" || a == "aarch64" {
		a = "arm64"
	}
	return a
}

func getFileExt(s string) string {
	return fileExtRe.FindString(s)
}
