#!/bin/bash -l

################################################################################
#
# Standardize pulling and pushing among svn and git
#

# PULL / UPDATE
function pll() {
    OUT="$(svn up 2> /dev/null)"
    if [[ $? -eq 0 ]]; then
        echo "$OUT"
        return 0
    fi

    OUT="$(git pull 2> /dev/null)"
    if [[ $? -eq 0 ]]; then
        echo "$OUT"
        return 0
    fi

    echo "Not svn or git"
    return 1
}

# PUSH / COMMIT
function psh() {
    svn st 2&>1 /dev/null
    if [[ $? -eq 1 ]]; then
        svn ci
        return $?
    fi

    git status 2&>1 /dev/null
    if [[ $? -eq 128 ]]; then
        git add .
    fi
    git status 2&>1 /dev/null
    if [[ $? -eq 128 ]]; then
        git commit
        if [[ $? -eq 0 ]]; then
            git push
        fi
        return $?
    fi

    echo "Not svn or git"
    return 1
}

# STATUS
function st() {
    OUT="$(git status)"
    if [[ $? -eq 0 ]]; then
        echo "$OUT"
        return 0
    fi

    svn st
    return $?
}

# Show the git branch at command line
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
