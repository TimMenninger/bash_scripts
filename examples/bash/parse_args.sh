#!/bin/bash

# RETRIEVED FROM: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
    -e|--extension)
        shift # past option
        EXTENSION="$1"
        ;;
    -s|--searchpath)
        shift # past option
        SEARCHPATH="$1"
        ;;
    --falls-through)
        echo "falling through"
        ;;&
    --default)
        DEFAULT=YES
        ;;
    -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
    *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        ;;
    esac
    shift # past argument
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
