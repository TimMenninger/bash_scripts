#!/bin/bash -l

# SVN...
alias svnstat="svn status -q"
alias svnr="svn resolve --accept working"
alias sup="svn up --non-interactive; echo -e \"\\\\a\"; sleep .25; echo -e \"\\\\a\""
alias gbas="sup && ./builds-ep/build_all.sh"

alias svn16="/archive/subversion/1.6/subversion-1.6.9/subversion/svn/svn"
alias svn17="/archive/subversion/1.7/subversion-1.7.17/subversion/svn/svn"

function svn_mass_propset() {
    while [[ $# -gt 0 ]];
    do
        /usr/bin/svn propset svn:mime-type text/plain $1
        /usr/bin/svn propset svn:eol-style native $1
        shift
    done
}

function svn() {
    # Handle commits
    if [[ "$1" == "ci" || "$1" == "commit" ]]; then
        # Get the status
        STATUS=$(/usr/bin/svn st)

        # Check for bad files
        TEST=$(echo "$STATUS" | grep "^!")
        if [[ "$TEST" == "" ]]; then
            TEST=$(echo "$STATUS" | grep "^?")
        fi
        if [[ "$TEST" != "" ]]; then
            echo "$STATUS"
            return 1
        fi
    fi

    # If here, can svn as normal
    /usr/bin/svn $@
    return $?
}

# Add or delete all unknowns
function svn_mass_add() {
    # Non binary files
    svn st | grep '^?' | grep -v 'Binary' | sed 's/^?\S*/svn add /g' > /tmp/svn_add_list
    sed -i 's/\(.*\@.*\)/\1\@/g' /tmp/svn_add_list
    source /tmp/svn_add_list
    sed -i 's/^svn add /svn propset svn:mime-type text\/plain /g' /tmp/svn_add_list
    source /tmp/svn_add_list
    sed -i 's/mime-type text\/plain/eol-style native/g' /tmp/svn_add_list
    source /tmp/svn_add_list

    # Binary files
    svn st | grep '^?' | grep 'Binary' | grep 'bmp' | sed 's/^?\S*/svn add /g' > /tmp/svn_add_list
    source /tmp/svn_add_list
    sed -i 's/^svn add /svn propset svn:mime-type application\/octet-stream /g' /tmp/svn_add_list
    source /tmp/svn_add_list

    rm /tmp/svn_add_list
}

function svn_mass_del() {
    svn st | grep '^\!' | sed 's/^\!\S*/svn del --force /g' > /tmp/svn_del_list
    source /tmp/svn_del_list
    rm /tmp/svn_del_list
}
