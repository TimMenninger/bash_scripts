#!/bin/bash

function cleanup {
    echo "HERE"
}
trap cleanup EXIT

exit 1
