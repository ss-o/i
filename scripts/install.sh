#!/usr/bin/env bash

trap '_cleanup' EXIT INT TERM

declare -r DEBUG="${DEBUG:-false}"
declare -i exit_code=0

[[ "$DEBUG" == "true" ]] && set -x

_workdir=$(mktemp -d -t i-XXXXXXXXXX)

_has_terminal() { [[ -t 0 ]]; }
_is_tty() { _has_terminal; }
_is_piped() { [[ ! -t 1 ]]; }
_is_root() { [[ "$(id -u)" -eq 0 ]]; }
_has_cmd() { command -v "$@" >/dev/null 2>&1 || say_err "command not found: $1"; }
_cmd() { command "$@"; }
_cmd_exists() { command -v "$@" >/dev/null 2>&1; }
_cmd_read() { _cmd read -r -a args <<< "$@"; _cmd "${args[@]}"; }
_exec_as_user() { _cmd su -c "$@" "$USER"; }
_exec_as_root() { _cmd sudo -E "$@" &> /dev/null; }
_exec_as() { [[ "$EUID" -eq 0 ]] && _exec_as_root "$@" || _exec_as_user "$@"; }
_set_auth() {
	if [[ $_allow_insecure_traffic != true ]]; then
		if [[ -n "${GITHUB_TOKEN}" ]]; then
			declare _header_="'Authorization: Bearer ${GITHUB_TOKEN}'"
			declare _opts_="-H ${_header_}"
		else
			declare _opts_=""
		fi
	else
	  [[ -n "${GITHUB_TOKEN}" ]] && unset GITHUB_TOKEN
		say -red "authorization disabled (insecure traffic allowed)"
    declare _opts_=""
	fi
}

say() {
	declare rst="\033[00m"
	declare one_line=false
  while [ -n "$1" ]; do
    case "$1" in
			-normal) col="\033[00m" ;;
			-black) col="\033[30;01m" ;;
			-red) col="\033[31;01m" ;;
			-green) col="\033[32;01m" ;;
			-yellow) col="\033[33;01m" ;;
			-blue) col="\033[34;01m" ;;
			-magenta) col="\033[35;01m" ;;
			-cyan) col="\033[36;01m" ;;
			-white) col="\033[37;01m" ;;
			-n) one_line=true; shift; continue ;;
			*) printf '%s' "${1}"; shift; continue ;;
    esac
		shift
		printf "${col}%s${rst}" "$1"; shift
  done
  [[ "${one_line}" == true ]] || printf "\n"
}

say_ok() { printf "\033[34;1m▓▒░\033[32;01m ✔ \033[00m» "; say -green "$1"; }
say_err() { printf "\033[34;01m▓▒░\033[31;01m ✘ \033[00m» "; say -red "$1" >&2; exit 1; }
_cleanup() { _cmd rm -rf $_workdir &> /dev/null; }
_err() { _cleanup; msg=$1; shift; say_err "Error: $msg"; }

_install() {
	declare _owner _program _renamed_program _move_to _release _has_m1
	declare _allow_insecure_traffic _output_directory _github_url _github_api

	_owner="{{ .User }}"
	_program="{{ .Program }}"
	# Force rename binary '?as=...'
	_renamed_program="{{ .AsProgram }}"
	_move_to="{{ .MoveToPath }}"
	_release="{{ .Release }}"
	_has_m1="{{ .M1Asset }}"
	_allow_insecure_traffic="{{ .Insecure }}"
	_output_directory="{{ if .MoveToPath }}/usr/local/bin{{ else }}$(pwd){{ end }}"
	_github_url="https://github.com"
	_github_api="https://api.github.com"

	[[ -n "$BASH_VERSION" ]] || _err "Please use bash instead"
	[[ -d $_output_directory ]] || _err "output directory missing: $_output_directory"

	# check for required commands
	declare -a dependencies=(uname mktemp grep cut tr sed sort uniq wc head tail basename dirname rm mv mkdir chmod find xargs cut du)
	for dep in "${dependencies[@]}"; do _has_cmd $dep; done

	#choose an HTTP client
	get_source() {
		declare -a _clients_=(curl wget)
		for GET in "${_clients_[@]}"; do _cmd_exists $GET && break; done
		case $GET in
		curl)
			[[ "$DEBUG" == "true" ]] && _dbg="--verbose" || _dbg="--silent"
			#[[ $_allow_insecure_traffic == "true" ]] && _sec="--insecure" || _sec=""
			_opts_="${_opts_} ${_sec} --show-error --location --retry 3 --progress-bar --fail ${_dbg} -o -"
			;;
		wget)
			[[ "$DEBUG" == "true" ]] && _dbg="--verbose" || _dbg="--quiet"
			#[[ $_allow_insecure_traffic == "true" ]] && _sec="--no-check-certificate" || _sec=""
			_opts_="${_opts_} ${_sec} --tries=3 --progress=bar ${_dbg} -O -"
			;;
		*)
			_err "no HTTP client found, please install curl or wget and try again"
			;;
		esac
		_set_auth; _cmd ${GET} ${_opts_} -- "$@"
	}

	OS=$(command uname | tr '[:upper:]' '[:lower:]')
  case $OS in
		android*) OS='android' ;;
		darwin*) OS='darwin' ;;
		linux*) OS='linux' ;;
		freebsd*) OS='freebsd' ;;
		netbsd*) OS='netbsd' ;;
		openbsd*) OS='openbsd' ;;
		sunos*) OS='solaris' ;;
		msys* | cygwin* | mingw* | win*) OS='windows' ;;
		*) [[ -z "$OS" ]] && OS='unknown' ;;
  esac

	#find ARCH
	ARCH="$(command uname -m | tr '[:upper:]' '[:lower:]')"
  case $ARCH in
		x86_64 | amd64 | x64*) ARCH='amd64' ;;
		i?86 | x86) ARCH='386' ;;
		aarch64* | arm64*) ARCH='arm64' ;;
		armv6l | armv7l | arm*) ARCH='arm' ;;
		*) [[ -z "$ARCH" ]] && ARCH='unknown' ;;
  esac

	# check for macos m1 assets
	#{{if not .M1Asset}}
	# no m1 assets. if on mac arm64, rosetta allows fallback to amd64
	[[ $_has_m1 == "false" ]] && [[ $OS = "darwin" ]] && [[ $ARCH = "arm64" ]] && ARCH="amd64"
	#[[ $OS = "darwin" ]] && ARCH="amd64"
	#{{end}}

	declare -a _pm_list_=(dpkg rpm dnf brew apk pacman)
	for _pm_ in "${_pm_list_[@]}"; do _cmd_exists $_pm_ && break; done
	case $_pm_ in
		dpkg) MTYPE=".deb" ;;
		rpm | dnf) MTYPE=".rpm" ;;
		brew) MTYPE="" ;;
		apk) MTYPE=".apk" ;;
		pacman) MTYPE="" ;;
		*) MTYPE="" ;;
	esac
	declare URL="" FTYPE=""
	# trunk-ignore(shfmt/parse)
	case "${OS}_${ARCH}" in{{range .Assets}}
	"{{.OS}}_{{.Arch}}")
		URL="{{.URL}}"
		case "$MTYPE" in
			"{{.Type}}") FTYPE="$MTYPE" ;;
			*) FTYPE="{{.Type}}" ;;
		esac
		;;{{end}}
	*) _err "No asset for platform ${OS}-${ARCH}" ;;
	esac

	say -n -white "Found "
	say -n -green "${_owner}/${_program}"

	[[ -n "$_release" ]] && say -n " $_release"
	[[ -n "$_renamed_program" ]] && say -n " as $_renamed_program"

	say -n -yellow " ${OS}/${ARCH} "
	{{if .Google}}
	# matched using google, give time to cancel
	say -n "{{if .MoveToPath}}installing{{else}}downloading{{end}} in "
	for i in 6 5 4 3 2 1; do sleep 1; say -n -red "$i "; done
	say -green '➜ fetching...'
	{{ else }}
	say -green '➜ {{if .MoveToPath}}installing{{else}}downloading{{end}}...'
	{{ end }}

	# create a temp directory to work in
	_cmd mkdir -p $_workdir || _err "failed to create $_workdir"
	_cmd cd $_workdir || _err "failed to cd into $_workdir"

	case $FTYPE in
	".zip")
		_has_cmd unzip
		get_source $URL > tmp.zip || _err "download failed"
		_cmd unzip -o -qq tmp.zip || _err "unzip failed"
		_cmd rm tmp.zip || _err "cleanup failed"
		;;
	".gz")
		_has_cmd gzip
		get_source $URL | _cmd gzip -d - > $_program || _err "download failed"
		;;
	".tar.bz" | ".tar.bz2")
		_has_cmd tar && _has_cmd bzip2
		get_source $URL | _cmd tar jxf - || _err "download failed"
		;;
	".tar.gz" | ".tgz")
		_has_cmd tar && _has_cmd gzip
		get_source $URL | _cmd tar zxf - || _err "download failed"
		;;
	".tar.xz")
		_has_cmd tar && _has_cmd xz
		get_source $URL | _cmd tar Jxf - || _err "download failed"
		;;
	".tar")
		_has_cmd tar
		get_source $URL | _cmd tar xf - || _err "download failed"
		;;
	".deb")
		_has_cmd dpkg
		get_source $URL > tmp.deb || _err "download failed"
		_cmd dpkg -x tmp.deb . || _err "dpkg failed"
		_cmd rm tmp.deb || _err "cleanup failed"
		;;
	".rpm")
		# TODO: rpm2cpio is not available on all platforms
		_has_cmd rpm2cpio
		get_source $URL > tmp.rpm || _err "download failed"
		_cmd rpm2cpio tmp.rpm | _cmd cpio -idmv || _err "rpm failed"
		_cmd rm tmp.rpm || _err "cleanup failed"
		;;
	".7z")
		_has_cmd 7z
		get_source $URL > tmp.7z || _err "download failed"
		_cmd 7z x tmp.7z || _err "7z failed"
		_cmd rm tmp.7z || _err "cleanup failed"
		;;
	".xz")
		_has_cmd xz
		get_source $URL | _cmd xz -d - > $_program || _err "download failed"
		;;
	".bz2" | ".bz")
		_has_cmd bzip2
		get_source $URL | _cmd bzip2 -d - > $_program || _err "download failed"
		;;
	".rar")
		_has_cmd unrar
		get_source $URL > tmp.rar || _err "download failed"
		_cmd unrar x tmp.rar || _err "unrar failed"
		_cmd rm tmp.rar || _err "cleanup failed"
		;;
	".jar")
		_has_cmd java
		get_source $URL > tmp.jar || _err "download failed"
		_cmd java -jar tmp.jar || _err "java failed"
		_cmd rm tmp.jar || _err "cleanup failed"
		;;
	".dmg")
		_has_cmd hdiutil
		get_source $URL > tmp.dmg || _err "download failed"
		_cmd hdiutil attach tmp.dmg || _err "hdiutil failed"
		_cmd rm tmp.dmg || _err "cleanup failed"
		;;
	".pkg")
		_has_cmd pkgutil
		get_source $URL > tmp.pkg || _err "download failed"
		_cmd pkgutil --expand tmp.pkg . || _err "pkgutil failed"
		_cmd rm tmp.pkg || _err "cleanup failed"
		;;
	".bin")
		get_source $URL > "{{ .Program }}_${OS}_${ARCH}" || _err "download failed"
		;;
	*)
		[[ -z "$FTYPE" ]] && FTYPE="unknown"
		[[ -z "$URL" ]] && URL="unknown"
		;;
	esac

	# search subtree largest file (bin)
	declare _workdir=$(_cmd find . -type f | xargs du | sort -n | tail -n 1 | cut -f 2)
	[[ -f "$_workdir" ]] || _err "could not find find binary (largest file)"

	# ensure its larger than 1MB
	[[ $(_cmd du -m $_workdir | cut -f1) -lt 1 ]] && _err "no binary found ($_workdir is not larger than 1MB)"

	# move into PATH or cwd
	_cmd chmod +x $_workdir || _err "failed to chmod +x $_workdir"
	declare _target="${_output_directory}/${_program}"
	[[ -n "$_renamed_program" ]] && _target="${_output_directory}/${_renamed_program}"

	# attempt to move without superuser privileges
	_output=$(_cmd mv $_workdir $_target 2>&1); exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		if [[ $_output =~ "Permission denied" ]]; then
			_exec_as_root mv $_workdir $_target || _err "moving from $_workdir to $_target failed"
		else
			_err "missing permissions to move $_output from $_workdir to $_target"
		fi
	fi

	say_ok "{{if .MoveToPath}}Installed at{{else}}Downloaded to{{end}} $_target"

	_cleanup
}

_install "$@"
