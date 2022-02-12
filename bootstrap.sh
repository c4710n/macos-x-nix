#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils-prefixed

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage() {
    echo "Select a valid hostname first."
}

HOSTNAME=$1
SELECTED_HOST="${CWD}/hosts/${HOSTNAME}.nix"

if [[ -n $HOSTNAME && -f $SELECTED_HOST ]]; then
    grm -rf ~/.nixpkgs
    gln -snf "${CWD}" ~/.nixpkgs

    gln -snfr "${SELECTED_HOST}" "${CWD}"/hosts/current.nix
else
    usage
    exit 1
fi
