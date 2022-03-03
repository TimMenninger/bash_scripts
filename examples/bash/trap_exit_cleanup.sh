#!/bin/bash

# https://stackoverflow.com/questions/2129923/how-to-run-a-command-before-a-bash-script-exits

function cleanup {
  echo "Removing /tmp/foo"
    rm  -r /tmp/foo
}

trap cleanup EXIT
mkdir /tmp/foo
asdffdsa #Fails
