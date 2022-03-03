#!/bin/bash -l

alias vm="ssh root@irdv-tmenninger"

export PATH=$PATH:/usr/local/go/bin

function nested_vm() {
    if [ $# -ne 2 ]; then
        echo "usage: nested_vm <VM_NAME> <IMG_PATH>"
        return 1
    fi

    NAME=$1
    IMG=$2

    virsh destroy $NAME
    virsh undefine $NAME
    virt-install --name $NAME --ram 2048 --vcpu 4 --disk $IMG --import --os-variant ubuntutrusty
}

function smeld() {
    if [ $# -ne 2 ]; then
        echo "Must give 2 files"
        return 1
    fi

    if [[ "$(hostname)" != "tmenninger--MacBookPro16" ]]; then
        echo "Must be on mac"
        return 1
    fi

    FILE1=$1
    FILE2=$2

    meld <(ssh root@irdv-tmenninger cat $FILE1) <(ssh root@irdv-tmenninger cat $FILE2)
}

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

    git checkout feature/darforce && git pull

    BRANCH_NAME=users/tmenninger/$JIRA
    git checkout -b $BRANCH_NAME && git push -u origin $BRANCH_NAME
}

function rs2vm() {
    $SCRIPTS_PATH/tools/rs2vm.sh
}
function rs2mac() {
    $SCRIPTS_PATH/tools/rs2mac.sh
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

