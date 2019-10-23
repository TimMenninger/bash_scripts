#!/bin/bash -l

# This just copies all of the vim plugins to ~/.vim/bundle, creating the
# directories if needed
if [ -z "$SCRIPTPATH" ]; then
    echo "SCRIPTPATH not set"
fi

if [ ! -d ~/.vim ]; then
    mkdir ~/.vim
fi

if [ ! -d ~/.vim/bundle ]; then
    mkdir ~/.vim/bundle
fi

cp -rf ${SCRIPTPATH}/vim_plugins/* ~/.vim/bundle/
