#!/bin/bash -l

alias vm="ssh ir@irdv-tmenninger"

function gbrj() {
    # Checks out a (g)it (br)anch for (j)ira. Argument should be the jira, e.g.
    # IR-#####

    JIRA=$1
    if [ -z "$JIRA" ]; then
        echo "ERROR: must supply jira"
        echo "usage: gbrj <JIRA>"
        echo "        will create a branch called users/tmenninger/<JIRA>"
        return 1
    fi

    BRANCH_NAME=users/tmenninger/$JIRA
    git checkout -b $BRANCH_NAME && git push -u origin $BRANCH_NAME
}

function rs2vm() {
    REMOTE_HOST=ir@irdv-tmenninger

    SRC=/Users/tmenninger/code/ir-tmenninger
    DST=$REMOTE_HOST:/home/ir/code

    # NOTE: only to be used from mac
    if [ ! -d $SRC ]; then
        echo "expect $SRC to exist"
        echo "NOTE: only to be used from mac terminal"
        return 1
    fi

    $SCRIPTS_PATH/tools/rsync.sh $SRC $DST
}
function rs2mac() {
    REMOTE_HOST=ir@irdv-tmenninger

    SRC=$REMOTE_HOST:/home/ir/code/ir-tmenninger
    DST=/Users/tmenninger/code

    # NOTE: only to be used from mac
    if [ ! -d $DST ]; then
        echo "expect $DST to exist"
        echo "NOTE: only to be used from mac terminal"
        return 1
    fi

    $SCRIPTS_PATH/tools/rsync.sh $SRC $DST
}

function code() {
    cd /code/$1
}

# Create ssh keys
function ssh_key() {
    REMOTE_ADDRESS=$1

    # validity
    if [ -z "$REMOTE_ADDRESS" ]; then
        echo "usage: ssh_key USER@HOST"
        return 1
    fi

    # creates an RSA key with 4096 bytes
    yes "" | ssh-keygen -t rsa -b 4096 -C "tmenninger@purestorage.com"

    # copies key to remote address
    ssh-copy-id -i ~/.ssh/id_rsa.pub $REMOTE_ADDRESS

    # copy public key to authorized_keys in remote host
    cat ~/.ssh/id_rsa.pub | ssh $REMOTE_ADDRESS "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

    # add the SSH private key into the SSH authentication agent
    yes "" | ssh-add
}

