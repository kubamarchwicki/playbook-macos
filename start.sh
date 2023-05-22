#!/bin/bash

set -e

REPOSITORY="https://github.com/kubamarchwicki/playbook-macos.git"
TARGET="$(pwd)"

RED=""
GREEN=""
BLUE=""
RESET=""

error() {
    echo "${RED}""Error: $*""${RESET}" >&2
    exit 1
}

ok() {
    echo "${GREEN}""Info   | OK        | $*""${RESET}"
}

installing() {
    echo "${BLUE}""Info   | Install   | $*""${RESET}"
}

generate_temp_dir() {
    PLAYBOOK_LOCATION=$(mktemp -d -t playbookXXX)
    trap 'rm -rf "$PLAYBOOK_LOCATION"' EXIT
    git clone -q --depth=1 "${REPOSITORY}" "$PLAYBOOK_LOCATION" || error "git clone of playbook repo failed, run with --local if already cloned"
    TARGET="$PLAYBOOK_LOCATION"
}

if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    BLUE=$(printf '\033[34m')
    RESET=$(printf '\033[m')
fi

if [[ $(/usr/bin/gcc 2>&1) =~ "no developer tools were found" ]] || [[ ! -x /usr/bin/gcc ]];
    then
        installing "xcode"
        xcode-select --install
    else
        ok "xcode"
fi

if [[ ! -x /opt/Homebrew/bin ]];
    then
        installing "homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        export PATH="/opt/homebrew/bin:$PATH"
    else
        ok "homebrew"
fi

if [[ ! -x /opt/Homebrew/bin ]];
    then
        installing "homebrew"
        /opt/Homebrew/bin/brew update
        /opt/Homebrew/bin/brew install ansible
    else
        ok "ansible"
fi


[[ "$1" = "--local" ]] && echo "Using local copy" || generate_temp_dir

export PATH=/usr/local/bin:$PATH

cd "$TARGET" && ansible-playbook playbook.yml -K 
