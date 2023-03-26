package handler

import (
	"regexp"
	"strings"
)

var (
	osRe       = regexp.MustCompile(`(linux|(net|free|open)bsd|dragonfly|sunos|darwin|mac(|os)|osx|windows|cygwin|win)`)
	archRe     = regexp.MustCompile(`(amd64|x86_64|armv6l|armv7l|arm|aarch64|i?86|32|64)`)
	fileExtRe  = regexp.MustCompile(`(\.[a-z][a-z0-9]+)+$`)
	checksumRe = regexp.MustCompile(`(checksums|sha256sums|sha256sum|sha256)`)
)

func getOS(s string) string {
	// os detection
	s = strings.ToLower(s)
	o := osRe.FindString(s)
	// os modifications
	if o == "win" || o == "cygwin" {
		o = "windows"
	} else if o == "macos" || o == "osx" || o == "mac" {
		o = "darwin"
	} else if o == "sunos" {
		o = "solaris"
	}

	return o
}

func getArch(s string) string {
	// arch detection
	s = strings.ToLower(s)
	a := archRe.FindString(s)
	// arch modifications
	if a == "64" || a == "x86_64" || a == "" {
		a = "amd64" //default
	} else if a == "i686" || a == "i386" || a == "32" || a == "86" {
		a = "386"
	} else if a == "aarch64" {
		a = "arm64"
	} else if a == "armv6l" || a == "armv7l" {
		a = "arm"
	}

	return a
}

func getFileExt(s string) string {
	return fileExtRe.FindString(s)
}

func splitHalf(s, by string) (string, string) {
	i := strings.Index(s, by)
	if i == -1 {
		return s, ""
	}
	return s[:i], s[i+len(by):]
}
