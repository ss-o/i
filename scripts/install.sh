#!/usr/bin/env bash

TMP_DIR="/tmp/tmpinstalldir"
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
        OS='osx'
        ;;
    SunOS)
        OS='solaris'
        ;;
    *)
        fail 'OS not supported'
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
    *)
        fail 'OS type not supported'
        ;;
    esac
}
cleanup() {
	echo rm -rf $TMP_DIR > /dev/null
}
fail() {
	cleanup
	msg=$1
	echo "============"
	echo "Error: $msg" 1>&2
	exit 1
}
install() {
	[ ! "$BASH_VERSION" ] && fail "Please use bash instead"
	[ ! -d $OUT_DIR ] && fail "output directory missing: $OUT_DIR"
	which find > /dev/null || fail "find not installed"
	which xargs > /dev/null || fail "xargs not installed"
	which sort > /dev/null || fail "sort not installed"
	which tail > /dev/null || fail "tail not installed"
	which cut > /dev/null || fail "cut not installed"
	which du > /dev/null || fail "du not installed"
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
		fail "neither wget/curl are installed"
	fi
	URL=""
	FTYPE=""
	case "${OS}_${ARCH}" in {{ range .Assets }}
	"{{ .OS }}_{{ .Arch }}")
		URL="{{ .URL }}"
		FTYPE="{{ .Type }}"
		;;{{end}}
	*) fail "No asset for platform ${OS}-${ARCH}";;
	esac
	echo -n "{{ if .MoveToPath }}Installing{{ else }}Downloading{{ end }} $USER/$PROG $RELEASE"
	{{ if .Google }}
	echo -n " in 5 seconds"
	for i in 1 2 3 4 5; do
		sleep 1
		echo -n "."
	done
	{{ else }}
	echo "....."
	{{ end }}
	mkdir -p $TMP_DIR
	cd $TMP_DIR
	if [[ $FTYPE = ".gz" ]]; then
		which gzip > /dev/null || fail "gzip is not installed"
		#gzipped binary
		NAME="${PROG}_${OS}_${ARCH}.gz"
		GZURL="$GH/releases/download/$RELEASE/$NAME"
		#gz download!
		bash -c "$GET $URL" | gzip -d - > $PROG || fail "download failed"
	elif [[ $FTYPE = ".tar.gz" ]] || [[ $FTYPE = ".tgz" ]]; then
		which tar > /dev/null || fail "tar is not installed"
		which gzip > /dev/null || fail "gzip is not installed"
		bash -c "$GET $URL" | tar zxf - || fail "download failed"
	elif [[ $FTYPE = ".zip" ]]; then
		which unzip > /dev/null || fail "unzip is not installed"
		bash -c "$GET $URL" > tmp.zip || fail "download failed"
		unzip -o -qq tmp.zip || fail "unzip failed"
		rm tmp.zip || fail "cleanup failed"
	elif [[ $FTYPE = "" ]]; then
		bash -c "$GET $URL" > "{{ .Program }}_${OS}_${ARCH}" || fail "download failed"
	else
		fail "unknown file type: $FTYPE"
	fi
	#search subtree largest file (bin)
	TMP_BIN=$(find . -type f | xargs du | sort -n | tail -n 1 | cut -f 2)
	if [ ! -f "$TMP_BIN" ]; then
		fail "could not find find binary (largest file)"
	fi
	#ensure its larger than 1MB
	if [[ $(du -m $TMP_BIN | cut -f1) -lt 1 ]]; then
		fail "no binary found ($TMP_BIN is not larger than 1MB)"
	fi
	#move into PATH or cwd
	chmod +x $TMP_BIN || fail "chmod +x failed"
	{{ if .SudoMove }}echo "using sudo to move binary..."{{ end }}
	{{ if .SudoMove }}sudo {{ end }}mv $TMP_BIN $OUT_DIR/$PROG || fail "mv failed" #FINAL STEP!
	echo "{{ if .MoveToPath }}Installed at{{ else }}Downloaded to{{ end }} $OUT_DIR/$PROG"
}

while true; do
	GET_OS
	OS_TYPE
	install
	cleanup
done
