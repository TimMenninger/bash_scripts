#!/bin/bash -l

alias vm='ssh ir@irdv-tmenninger'

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

