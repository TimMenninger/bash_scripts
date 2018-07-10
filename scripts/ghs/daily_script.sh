#!/bin/bash
source ~/.bashrc

# Go to nh directory
nh2017

# Create patch in case we botch things
svn diff > /home/willow/tools/diff.patch

# Update
/usr/bin/svn up

# List of all directories to cd into for gbuild, relative to nh2017 directory
declare -a PROJ_DIRS=(
    "./linux64"
    "./rcar_dynamic"
    "./rcar_dynamic_no_android"
    "./rcar_simple"
    "./simarm64"
)

# Build all
for i in "${arr[@]}"
do
    nh2017
    cd $i
    rm -rf bin/* objs/* hist/*
    gbuild -cleanfirst
done

