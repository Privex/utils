#!/usr/bin/env bash

# directory where the script is located, so we can source files regardless of where PWD is
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${DIR}/lib.sh"

declare -A dkrs

dkrs[Ubuntu]="dkr/ubuntu/Dockerfile"
dkrs["CentOS 7"]="dkr/centos7/Dockerfile"
dkrs["CentOS 8"]="dkr/centos8/Dockerfile"
dkrs["Oracle Linux"]="dkr/oracle/Dockerfile"
dkrs["Alpine Linux"]="dkr/alpine/Dockerfile"

simple-name() {
    basename "$(dirname "$1")"
}

: ${DOCKER_EXE="docker"}
: ${CT_TAG="bashutils"}

DOCKER_ARGS=(${@:1})

if ! has-cmd "$DOCKER_EXE"; then
    msgerr bold red " [!!!] Couldn't find Docker executable (DOCKER_EXE): '${DOCKER_EXE}'"
    msgerr red " [!!!] To easily install Docker on unix-based systems (Linux, BSD, MacOS), run the following command:\n"
    msgerr "     curl -fsS https://get.docker.com | sh\n"
    exit 5
fi

declare -A results
declare -A results_run


for k in "${!dkrs[@]}"; do
    msgerr bold yellow "\n =============================================================== \n"
    d="${dkrs[$k]}"
    simpname="$(simple-name "$d")"
    dtag="${CT_TAG}:${simpname}"

    msgerr bold cyan " >>> Building image '${dtag}' from docker file: $d"
    msgerr cyan      "     Tag:         $dtag     ||  Docker File: $d"
    msgerr cyan      "     Docker EXE:  $DOCKER_EXE      || Build Dir: $DIR"
    msgerr cyan      "     Docker args: ${DOCKER_ARGS[*]}"
    msgerr "\n"

    error_control 1
    #false 
    "$DOCKER_EXE" build "${DOCKER_ARGS[@]}" -t "$dtag" -f "${DIR}/${d}" "$DIR"
    _ret=$?

    msgerr yellow      "\n -----------\n"
    if (( _ret != 0 )); then
        msgerr bold red    " [!!!] Non-zero return code detected (code: '${_ret}')"
        msgerr red         " [!!!] While building image '${dtag}' from docker file: $d"
        msgerr red         "       Tag:         $dtag     ||  Docker File: $d"
        msgerr red         "       Docker EXE:  $DOCKER_EXE      || Build Dir: $DIR"
        msgerr red         "       Docker args: ${DOCKER_ARGS[*]}"
        msgerr "\n"
    else
        msgerr bold green    " [+++] Process returned successful return code (0)"
        msgerr green         " [+++] Built OS '${k}' as Docker image '${dtag}' from docker file: $d"
        msgerr green         "       Tag:         $dtag     ||  Docker File: $d"
        msgerr green         "       Docker EXE:  $DOCKER_EXE      || Build Dir: $DIR"
        msgerr green         "       Docker args: ${DOCKER_ARGS[*]}"
        msgerr "\n"
    fi

    results["$k"]="$_ret"
    if (( _ret == 0 )); then
        error_control 1
        "$DOCKER_EXE" run "${DOCKER_ARGS[@]}" -it "$dtag"
        _ret=$?
        results_run["$k"]="$_ret"
        if (( _ret != 0 )); then
            msgerr bold red    " [!!!] Non-zero return code detected (code: '${_ret}')"
            msgerr red         " [!!!] While RUNNING image '${dtag}' from docker file: $d"
            msgerr red         "       Tag:         $dtag     ||  Docker File: $d"
            msgerr red         "       Docker EXE:  $DOCKER_EXE      || Build Dir: $DIR"
            msgerr red         "       Docker args: ${DOCKER_ARGS[*]}"
            msgerr "\n"
        else
            msgerr bold green    " [+++] Process returned successful return code (0)"
            msgerr green         " [+++] Successfully installed onto OS '${k}' via Docker image '${dtag}' from docker file: $d"
            msgerr green         "       Tag:         $dtag     ||  Docker File: $d"
            msgerr green         "       Docker EXE:  $DOCKER_EXE      || Build Dir: $DIR"
            msgerr green         "       Docker args: ${DOCKER_ARGS[*]}"
            msgerr "\n"
        fi
    fi

    #echo "Key: $k    || Value: $d"
done
msgerr bold yellow "\n =============================================================== \n"


msg bold yellow "Docker Container Building Results\n"
{
    for k in "${!results[@]}"; do
        res="${results[$k]}"
        if (( res == 0 )); then
            msg bold magenta " -> $k${RESET}^${BOLD}${GREEN}SUCCESS :)${RESET}^${BOLD}${CYAN}Code 0"
        else
            msg bold magenta " -> $k${RESET}^${BOLD}${RED}FAILED !!!${RESET}^${BOLD}${CYAN}Code ${res}"
        fi
    done;
} | pycolumn -s '^'


msg bold yellow "\nInstallation Runs in Docker\n"

{
    for k in "${!results_run[@]}"; do
        res="${results_run[$k]}"
        if (( res == 0 )); then
            msg bold magenta " -> $k${RESET}^${BOLD}${GREEN}SUCCESS :)${RESET}^${BOLD}${CYAN}Code 0"
        else
            msg bold magenta " -> $k${RESET}^${BOLD}${RED}FAILED !!!${RESET}^${BOLD}${CYAN}Code ${res}"
        fi
    done;
} | pycolumn -s '^'


