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

# directory where the script is located, so we can source files regardless of where PWD is
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${DIR}/lib.sh"

if ! install-pkg ${INST_PKGS[@]}; then
    msgerr yellow "\n [!!!] Failed to detect a supported package manager (supported: apt(-get), yum/dnf, brew, apk)"
    msgerr yellow " [!!!] Not installing libmemcached-dev, python3, python3-wheel, gcc, g++, or other important packages...\n"
fi

if (( EUID == 0 )); then
    [[ -n "$INST_POST" ]] && bash -c "$INST_POST"
else
    [[ -n "$INST_POST" ]] && sudo -H bash -c "$INST_POST"
fi
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
    "${DIR}/bin/pycolumn"
    "${DIR}/bin/sexy-copy"
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


#if [[ -n "$INST_CMD" ]]; then
#    msgerr yellow " [...] Installing all required packages using: $INST_CMD"
#    if (( EUID == 0 )); then
#        [[ -n "$INST_CMD_UPDATE" ]] && "$INST_CMD" "$INST_CMD_UPDATE"
#        if (( INST_SEP )); then
#            for p in "${INST_PKGS[@]}"; do
#                [[ -n "$INST_CMD_INSTALL" ]] && "$INST_CMD" "$INST_CMD_INSTALL" "$p"
#            done
#        else
#            [[ -n "$INST_CMD_INSTALL" ]] && "$INST_CMD" "$INST_CMD_INSTALL" "${INST_PKGS[@]}"
#        fi
#        [[ -n "$INST_POST" ]] && bash -c "$INST_POST"
#    else
#        [[ -n "$INST_CMD_UPDATE" ]] && sudo -H "$INST_CMD" "$INST_CMD_UPDATE"
#        if (( INST_SEP )); then
#            for p in "${INST_PKGS[@]}"; do
#                [[ -n "$INST_CMD_INSTALL" ]] && sudo -H "$INST_CMD" "$INST_CMD_INSTALL" "$p"
#            done
#        else
#            [[ -n "$INST_CMD_INSTALL" ]] && sudo -H "$INST_CMD" "$INST_CMD_INSTALL" "${INST_PKGS[@]}"
#        fi
#        [[ -n "$INST_POST" ]] && sudo -H bash -c "$INST_POST"
#    fi
#else
#    msgerr yellow "\n [!!!] Failed to detect a supported package manager (supported: apt(-get), yum/dnf, brew, apk)"
#    msgerr yellow " [!!!] Not installing libmemcached-dev, python3, python3-wheel, gcc, g++, or other important packages...\n"
#fi


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



