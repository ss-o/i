#!/usr/bin/env bash

TMP_DIR="/tmp/get-it"
USER="{{ .User }}"
PROG="{{ .Program }}"
MOVE="{{ .MoveToPath }}"
RELEASE="{{ .Release }}"
INSECURE="{{ .Insecure }}"
OUT_DIR="{{ if .MoveToPath }}/usr/local/bin{{ else }}$(pwd){{ end }}"
GH="https://github.com"

GET_OS() {
    OS="$(uname)"
    case "$OS" in
    Linux)
        OS='linux'
        ;;
    FreeBSD)
        OS='freebsd'
        ;;
    NetBSD)
        OS='netbsd'
        ;;
    OpenBSD)
        OS='openbsd'
        ;;
    Darwin)
        OS='darwin'
        ;;
    SunOS)
        OS='solaris'
        ;;
    *)
        ERROR 'OS not supported'
        ;;
    esac
}

OS_TYPE() {
    ARCH="$(uname -m)"
    case "$ARCH" in
    x86_64 | amd64)
        ARCH='amd64'
        ;;
    i?86 | x86)
        ARCH='386'
        ;;
    aarch64 | arm64)
        ARCH='arm64'
        ;;
    arm*)
        ARCH='arm'
        ;;
    mips*)
        ARCH='mips'
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
	msg="$1"
	echo "## ==================== ##"
	echo "Error: $msg" 1>&2
	exit 1
}
# shellcheck disable=SC1009
INSTALL () {
	[ ! "$BASH_VERSION" ] && ERROR "Please use bash instead"
	[ ! -d $OUT_DIR ] && ERROR "output directory missing: $OUT_DIR"
		which find > /dev/null || ERROR "find not installed"
		which xargs > /dev/null || ERROR "xargs not installed"
		which sort > /dev/null || ERROR "sort not installed"
		which tail > /dev/null || ERROR "tail not installed"
		which cut > /dev/null || ERROR "cut not installed"
		which du > /dev/null || ERROR "du not installed"
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
		ERROR "neither wget/curl are installed"
	fi
	URL=""
	FTYPE=""
# shellcheck disable=SC1072
# shellcheck disable=SC1073
# shellcheck disable=SC1083
# shellcheck disable=SC1085
	case "${OS}_${ARCH}" in {{ range .Assets }}
	"{{ .OS }}_{{ .Arch }}")
		URL="{{ .URL }}"
		FTYPE="{{ .Type }}"
	;;{{end}}
	*) ERROR "No asset for platform ${OS}_${ARCH}"
	;;
	esac

	echo -n "{{ if .MoveToPath }}Installing{{ else }}Downloading{{ end }} $USER/$PROG $RELEASE"
	{{ if .Google }}
	echo -n " in 5 seconds"
	for i in 1 2 3 4 5 6 7 8 9 10; do
		sleep 1
		echo -n "-"
	done
	{{ else }}
	echo "----------"
	{{ end }}

	mkdir -p $TMP_DIR
	cd $TMP_DIR

	if [[ $FTYPE = ".gz" ]]; then
		which gzip > /dev/null || ERROR "gzip is not installed"
		NAME="${PROG}_${OS}_${ARCH}.gz"
		GZURL="$GH/releases/download/$RELEASE/$NAME"
		bash -c "$GET $URL" | gzip -d - > $PROG || ERROR "download failed"
	elif [[ $FTYPE = ".tar.gz" ]] || [[ $FTYPE = ".tgz" ]]; then
		which tar > /dev/null || ERROR "tar is not installed"
		which gzip > /dev/null || ERROR "gzip is not installed"
		bash -c "$GET $URL" | tar zxf - || ERROR "download failed"
	elif [[ $FTYPE = ".zip" ]]; then
		which unzip > /dev/null || ERROR "unzip is not installed"
		bash -c "$GET $URL" > tmp.zip || ERROR "download failed"
		unzip -o -qq tmp.zip || ERROR "unzip failed"
		rm tmp.zip || ERROR "cleanup failed"
	elif [[ $FTYPE = "" ]]; then
		bash -c "$GET $URL" > "{{ .Program }}_${OS}_${ARCH}" || ERROR "download failed"
	else
		ERROR "Unknown file type: $FTYPE"
	fi

	TMP_BIN=$(find . -type f | xargs du | sort -n | tail -n 1 | cut -f 2)
	if [ ! -f "$TMP_BIN" ]; then
		ERROR "could not find find binary (largest file)"
	fi

	if [[ $(du -m $TMP_BIN | cut -f1) -lt 1 ]]; then
		ERROR "no binary found ($TMP_BIN is not larger than 1MB)"
	fi

	chmod +x $TMP_BIN || ERROR "chmod +x failed"
	{{ if .SudoMove }}echo "using sudo to move binary..."{{ end }}
	{{ if .SudoMove }}sudo {{ end }}mv $TMP_BIN $OUT_DIR/$PROG || ERROR "mv failed"
	echo "{{ if .MoveToPath }}Installed at{{ else }}Downloaded to{{ end }} $OUT_DIR/$PROG"
}

while true; do
	GET_OS
	OS_TYPE
	INSTALL
	CLEANUP
	exit 0
done
