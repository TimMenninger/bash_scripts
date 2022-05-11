#!/bin/bash

FILE1=
FILE2=

function usage() {
    echo "usage: cmplnx.sh [options] filepath"
    echo "        Compares two files from linux repo. The left is always the \"earlier\" one"
    echo "    options:"
    echo "        -p    Compares 5.4.95 patched and 5.15.24 patched"
    echo "        -c    Compares 5.15.24 patched and 5.15.24 patched"
    echo "        -5.4  Compares 5.4.95 clean and 5.4.95 patched"
    echo "        -5.15 Compares 5.15.24 clean and 5.15.24 patched"
    exit 1
}

function parse_args() {
    local positional_args=()

    repo1=
    repo2=
    relpath=

    # Options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                ;;
            -p)
                # Compares two patched versions
                repo1="linux-5.4.95-patched"
                repo2="linux-5.15.24-patched"
                ;;
            -c)
                # Compares two clean versions
                repo1="linux-5.4.95-clean"
                repo2="linux-5.15.24-clean"
                ;;
            -5.4)
                # Compares two 5.4.95 versions
                repo1="linux-5.4.95-clean"
                repo2="linux-5.4.95-patched"
                ;;
            -5.15)
                # Compares two 5.15.24 versions
                repo1="linux-5.15.24-clean"
                repo2="linux-5.15.24-patched"
                ;;
            *)
                positional_args+=("$1")
                ;;
        esac
        shift # past argument
    done
    if [ -z $repo1 ]; then
        usage
    fi

    set -- "${positional_args[@]}"

    # File (from repo top)
    if [[ $# -ne 1 ]]; then
        usage
    fi
    relpath="$1"

    # Files to compare
    FILE1="/code/${repo1}/${relpath}"
    FILE2="/code/${repo2}/${relpath}"
}

parse_args $@
echo "Comparing ${FILE1} and ${FILE2}"
meld <(ssh root@irdv-tmenninger cat $FILE1) <(ssh root@irdv-tmenninger cat $FILE2)
