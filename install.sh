#!/usr/bin/env bash
# Part of Privex/utils
#
# +===================================================+
# |                 © 2020 Privex Inc.                |
# |               https://www.privex.io               |
# +===================================================+
# |                                                   |
# |        Originally Developed for internal use      |
# |        at Privex Inc                              |
# |                                                   |
# |        Core Developer(s):                         |
# |                                                   |
# |          (+)  Chris (@someguy123) [Privex]        |
# |                                                   |
# |        Official Repo:                             |
# |                                                   |
# |           github.com/Privex/utils                 |
# |                                                   |
# +===================================================+
#
# Privex Utilities - easy system-wide installer 
# Copyright (c) 2020    Privex Inc. ( https://www.privex.io/ )
#
# License: GNU GPLv3
#
# Github: https://github.com/Privex/utils
#
############

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

error_control 0


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

: ${UTIL_INSTALL_DIR="/usr/local/bin"}

UTIL_INSTALL_DIR=$("${DIR}/bin/strip-end-slash" "$UTIL_INSTALL_DIR")

INSTALL_BINS=(
    "${DIR}/bin/check-seeds"
    "${DIR}/bin/copy-bin-chroot"
    "${DIR}/bin/detect-relpath"
    "${DIR}/bin/find-libs"
    "${DIR}/bin/geolocate"
    "${DIR}/bin/interlace-png"
    "${DIR}/bin/lib-copy"
    "${DIR}/bin/mk-user-chroot"
    "${DIR}/bin/mockscript"
    "${DIR}/bin/raid-part"
    "${DIR}/bin/strip-end-slash"
    "${DIR}/repos/slotmgr/slotmgr.sh"
)

STRIP_EXTENSION=(
    "${DIR}/repos/slotmgr/slotmgr.sh"
)

# _strip_ext [absolute_file_path]
# e.g. 
#   stripped=$(_strip_ext "/home/user/example.txt")
# stripped would equal "/home/user/example"
#
_strip_ext() {
    local fullpath="$1" srcdir orig_filename
    srcdir="$(dirname "$fullpath")" orig_filename=$(basename -- "$fullpath")
    local stripped_filename=${orig_filename%.*}
    echo "${srcdir}/${stripped_filename}"
}

# strip_ext [absolute_file_path]
# same as _strip_ext but only strips extension if path is in STRIP_EXTENSION array
strip_ext() {
    local fullpath="$1"
    if containsElement "$fullpath" "${STRIP_EXTENSION[@]}"; then
        _strip_ext "$fullpath"
    else
        echo "$fullpath"
    fi  
}


msg green " >>> Calling 'git submodule update --init --recursive' to ensure all external repos are downloaded..."
git submodule update --init --recursive

if ! can_write "$UTIL_INSTALL_DIR"; then
    msgerr yellow " [!!!] Current user doesn't have write permission for $UTIL_INSTALL_DIR"
    msgerr yellow " [!!!] Will try sudo."
    install() { sudo "install" "$@"; }
fi

msg green "\n >>> Installing binaries into ${UTIL_INSTALL_DIR} ...\n"

for f in "${INSTALL_BINS[@]}"; do
    stripped_dest="$(strip_ext "$f")"
    stripped_dest="$(basename "$stripped_dest")"

    install -v "$f" "${UTIL_INSTALL_DIR}/${stripped_dest}"
done

msg green "\n >>> Installing Python packages listed in requirements.txt ...\n"

if [[ "$(whoami)" != "root" ]]; then
    msgerr yellow " [!!!] Current user is not root, cannot install Python packages globally."
    msgerr yellow " [!!!] Will try sudo."
    sudo -H pip3 install -U -r requirements.txt
else
    pip3 install -U -r requirements.txt
fi

msg bold green "\n\n [+++] Finished installing/updating Privex utilities :)\n\n"



