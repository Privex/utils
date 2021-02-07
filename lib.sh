#!/usr/bin/env bash

has-cmd() {
    command -v "$@" &> /dev/null
}

msg() {
    (( $# > 0 )) && [[ "$1" == "red" || "$1" == "blue" || "$1" == "green" || "$1" == "yellow" || "$1" == "cyan" || "$1" == "magenta" || "$1" == "bold" ]] && shift
    (( $# > 0 )) && [[ "$1" == "red" || "$1" == "blue" || "$1" == "green" || "$1" == "yellow" || "$1" == "cyan" || "$1" == "magenta" || "$1" == "bold" ]] && shift
    echo -e "$@"
}

msgerr() {
    >&2 msg "$@"
}

INST_SEP=0 INST_CMD="" INST_CMD_UPDATE=() INST_CMD_INSTALL=() INST_POST="" X_UPDATED=0

if has-cmd apt || has-cmd apt-get; then
    has-cmd apt && INST_CMD="apt" || INST_CMD="apt-get"
    INST_CMD_UPDATE=(update "-qy") INST_CMD_INSTALL=("install" "-qy")
    INST_PKGS=(libmemcached-dev libmemcached11 build-essential python3 python3-pip python3-wheel python3-dev)
elif has-cmd dnf || has-cmd yum; then
    has-cmd dnf && INST_CMD="dnf" || INST_CMD="yum"
    INST_SEP=1 INST_CMD_UPDATE=("update" "-y") INST_CMD_INSTALL=("install" "-y")
    INST_PKGS=(libmemcached-devel libmemcached python3 python3-pip python3-devel python3-wheel gcc "gcc-c++")
elif has-cmd brew; then
    INST_CMD="brew"
    INST_CMD_UPDATE=(update) INST_CMD_INSTALL=(install)
    INST_SEP=1 INST_PKGS=(gcc libmemcached)
elif has-cmd apk; then
    INST_CMD="apk"
    INST_CMD_UPDATE=(update) INST_CMD_INSTALL=(add)
    INST_PKGS=(
        musl-dev linux-headers zlib-dev openssl-dev libffi-dev cairo-dev pango-dev
        gdk-pixbuf-dev gcc libmemcached libmemcached-dev python3 python3-dev
    )
    INST_SEP=1 INST_POST="python3 -m ensurepip; pip3 install -U pip;"
fi

install-pkg() {
    if [[ -z "$INST_CMD" ]]; then
        msgerr yellow " [!!!] Package manager not found. Cannot install packages: $*"
        return 2
    fi
    msgerr yellow " [...] Installing packages '$*' using: $INST_CMD"
    if (( EUID == 0 )); then
        (( X_UPDATED == 0 )) && (( ${#INST_CMD_UPDATE[@]} > 0 )) && "$INST_CMD" "${INST_CMD_UPDATE[@]}"
        X_UPDATED=1
        if (( INST_SEP )); then
            for p in "$@"; do
                (( ${#INST_CMD_INSTALL[@]} > 0 )) && "$INST_CMD" "${INST_CMD_INSTALL[@]}" "$p"
            done
        else
            (( ${#INST_CMD_INSTALL[@]} > 0 )) && "$INST_CMD" "${INST_CMD_INSTALL[@]}" "$@"
        fi
    else
        (( X_UPDATED == 0 )) && (( ${#INST_CMD_UPDATE[@]} > 0 )) && sudo -H "$INST_CMD" "${INST_CMD_UPDATE[@]}"
        X_UPDATED=1
        if (( INST_SEP )); then
            for p in "$@"; do
                (( ${#INST_CMD_INSTALL[@]} > 0 )) && sudo -H "$INST_CMD" "${INST_CMD_INSTALL[@]}" "$p"
            done
        else
            (( ${#INST_CMD_INSTALL[@]} > 0 )) && sudo -H "$INST_CMD" "${INST_CMD_INSTALL[@]}" "$@"
        fi
    fi
}

has-cmd git || install-pkg git
has-cmd which || install-pkg which
has-cmd wget || install-pkg wget
has-cmd curl || install-pkg curl
has-cmd grep || install-pkg grep
has-cmd sed || install-pkg sed
has-cmd awk || install-pkg awk

# Array of Privex ShellCore modules to be loaded during ShellCore initialisation.
SG_LOAD_LIBS=(gnusafe helpers trap_helper traplib)

# Error handling function for ShellCore
_sc_fail() { >&2 echo "Failed to load or install Privex ShellCore..." && exit 1; }

# If `load.sh` isn't found in the user install / global install, then download and run the auto-installer
# from Privex's CDN.
[[ -f "${HOME}/.pv-shcore/load.sh" ]] || [[ -f "/usr/local/share/pv-shcore/load.sh" ]] || \
    { curl -fsS https://cdn.privex.io/github/shell-core/install.sh | bash >/dev/null; } || _sc_fail

# Attempt to load the local install of ShellCore first, then fallback to global install if it's not found.
[[ -d "${HOME}/.pv-shcore" ]] && source "${HOME}/.pv-shcore/load.sh" || \
    source "/usr/local/share/pv-shcore/load.sh" || _sc_fail


# directory where the script is located, so we can source files regardless of where PWD is
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:${PATH}"
export PATH="${DIR}/bin:${HOME}/.local/bin:${PATH}"


