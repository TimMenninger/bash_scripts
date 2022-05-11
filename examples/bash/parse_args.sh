#!/bin/bash

# RETRIEVED FROM: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
    -e|--extension)
        EXTENSION="$2"
        shift # past argument
        shift # past value
        ;;
    -s|--searchpath)
        SEARCHPATH="$2"
        shift # past argument
        shift # past value
        ;;
    --falls-through)
        echo "falling through"
        ;;&
    --default)
        DEFAULT=YES
        shift # past argument
        ;;
    -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
    *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        shift # past argument
        ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
