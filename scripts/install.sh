#!/usr/bin/env bash

TMP_DIR="/tmp/i_temp"
ERR_LOG="/tmp/i.log"
GH="https://github.com"

USER="{{ .User }}"
PROG="{{ .Program }}"
MOVE="{{ .MoveToPath }}"
RELEASE="{{ .Release }}"
INSECURE="{{ .Insecure }}"
OUT_DIR="{{ if .MoveToPath }}/usr/local/bin{{ else }}$(pwd){{ end }}"

GET_OS() {
	OS="$(command -v uname)"
    case $( "${OS}" | tr '[:upper:]' '[:lower:]') in
    android*)
	OS='android'
	;;
    darwin*)
        OS='darwin'
        ;;
    linux*)
        OS='linux'
        ;;	
    freebsd*)
        OS='freebsd'
        ;;
    netbsd*)
        OS='netbsd'
        ;;
    openbsd*)
        OS='openbsd'
        ;;
    sunos*)
        OS='solaris'
        ;;
    msys*|cygwin*|mingw*)
	# OS='windows'
	ERROR 'OS not supported'	
	;;
    nt|win*)
	# OS='windows'
	ERROR 'OS not supported'
	;;
    *)
        ERROR 'OS not supported'
        ;;
    esac
}

GET_CPU() {
	ARCH="$(uname -m)"
    case "${ARCH}" in
    x86_64|amd64)
        ARCH='amd64'
        ;;
    i?86|x86)
        ARCH='386'
        ;;
    armv8*|aarch64|arm64)
        ARCH='arm64'
        ;;
    armv7*)
        ARCH='armv7'
        ;;
    armv6*)
        ARCH='armv6'
        ;;
    arm*)
        ARCH='arm'
	;;
    mips64le*)
        ARCH='mips64le'
	;;
    mips64*)
        ARCH='mips64'
	;;
    mipsle*)
        ARCH='mipsle'
	;;
    mips*)
        ARCH='mips'
	;;
    ppc64le*)
        ARCH='ppc64le'
	;;
    ppc64*)
        ARCH='ppc64'
	;;
    ppcle*)
        ARCH='ppcle'
	;;
    ppc*)
        ARCH='ppc'
	;;
    s390*)
	ARCH='s390x'
	;;
    *)
        ERROR 'OS type not supported'
        ;;
    esac
}

CLEANUP() {
	echo rm -rf $TMP_DIR > /dev/null
}

ERROR() {
	CLEANUP
	MSG="${1}"
	echo "# ================== #"
	echo "Error: $MSG" 1>&2
	exit 1
}

PRE_CHECK() {
	[ ! "$BASH_VERSION" ] && ERROR "(bash) required to run"
	[ ! -d $OUT_DIR ] && ERROR "(output directory) missing $OUT_DIR"
		which find > /dev/null || ERROR "(find) required to proceed"
		which xargs > /dev/null || ERROR "(xargs) required to proceed"
		which sort > /dev/null || ERROR "(sort) required to proceed"
		which tail > /dev/null || ERROR "(tail) required to proceed"
		which cut > /dev/null || ERROR "(cut) required to proceed"
		which du > /dev/null || ERROR "(du) required to proceed"
}

GET_URL() {
	GET=""
	if which curl > /dev/null; then
		GET="curl"
		if [[ $INSECURE = "true" ]]; then GET="$GET --insecure"; fi
		GET="$GET --fail -# -L"
	elif which wget > /dev/null; then
		GET="wget"
		if [[ $INSECURE = "true" ]]; then GET="$GET --no-check-certificate"; fi
		GET="$GET -qO-"
	else
		ERROR "(curl/wget) required to proceed"
	fi
	URL=""
	FTYPE=""
# shellcheck disable=SC1072
# shellcheck disable=SC1073
# shellcheck disable=SC1083
# shellcheck disable=SC1085
# shellcheck disable=SC1009
	case "${OS}_${ARCH}" in {{ range .Assets }}
	"{{ .OS }}_{{ .Arch }}")
		URL="{{ .URL }}"
		FTYPE="{{ .Type }}"
	;;{{end}}
	*) ERROR "Unable to find assets for ${OS}_${ARCH}"
	;;
	esac
}

INSTALL () {
	echo -n "{{ if .MoveToPath }}Installing{{ else }}Downloading{{ end }} $USER/$PROG $RELEASE"
	{{ if .Google }}
	echo -n " in 10 seconds"
	for i in 1 2 3 4 5 6 7 8 9 10; do
		sleep 1
		echo -n " >"
	done
	{{ else }}
	echo " > > > > > > > > > >"
	{{ end }}

	mkdir -p $TMP_DIR || ERROR "(command mkdir -p $TMP_DIR) failure"
	cd $TMP_DIR || ERROR "(command cd $TMP_DIR) failure"

	if [[ $FTYPE = ".gz" ]]; then
		which gzip > /dev/null || ERROR "(gzip) required to proceed"
		NAME="${PROG}_${OS}_${ARCH}.gz"
		GZURL="$GH/releases/download/$RELEASE/$NAME"
		bash -c "$GET $URL" | gzip -d - > $PROG || ERROR ""

	elif [[ $FTYPE = ".tar.gz" ]] || [[ $FTYPE = ".tgz" ]]; then
		which tar > /dev/null || ERROR "(tar) required to proceed"
		which gzip > /dev/null || ERROR "(gzip) required to proceed"
		bash -c "$GET $URL" | tar zxf - || ERROR "(download) process failure"

	elif [[ $FTYPE = ".zip" ]]; then
		which unzip > /dev/null || ERROR "(unzip) required to proceed"
		bash -c "$GET $URL" > tmp.zip || ERROR "(download) process failure"
		unzip -o -qq tmp.zip || ERROR "(unzip) process failure"
		rm tmp.zip || ERROR "(cleanup) process failure"

	elif [[ $FTYPE = "" ]]; then
		bash -c "$GET $URL" > "{{ .Program }}_${OS}_${ARCH}" || ERROR "(download) process failure"
	else
		ERROR "(file type $FTYPE) not supported"
	fi

	TMP_BIN=$(find . -type f | xargs du | sort -n | tail -n 1 | cut -f 2)
	if [ ! -f "$TMP_BIN" ]; then
		ERROR "(find binary) process failure"
	fi

	if [[ $(du -m $TMP_BIN | cut -f1) -lt 1 ]]; then
		ERROR "(file size 1MB) expected for $TMP_BIN"
	fi

	chmod +x $TMP_BIN || ERROR "(command chmod +x) failure"
	{{ if .SudoMove }}echo "using sudo to move binary..."{{ end }}
	{{ if .SudoMove }}sudo {{ end }}mv $TMP_BIN $OUT_DIR/$PROG || ERROR "(command mv) failure"
	echo "{{ if .MoveToPath }}Installed at{{ else }}Downloaded to{{ end }} $OUT_DIR/$PROG"
}

MAIN() {
	PRE_CHECK
	GET_OS
	GET_CPU
	GET_URL
	INSTALL
	CLEANUP
	exit 0
}

while true; do
	MAIN "${@}"
done
