#!/bin/bash -l

alias vm="ssh ir@irdv-tmenninger"
alias sim="irssh 10.255.8.20"
alias sf="/home/ir/scripts/tmenninger/pure/sync_forks.py -b master -B ^users/tmenninger/,^feature/ -j 16"

export PATH=/usr/local/go/bin:$PATH
export PATH=$SCRIPTS_PATH/pure/tools:$PATH
export PATH=/ir-scripts/ebadger:$PATH

alias ssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

function irssh() {
    sshpass -p welcome ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 ir@$*
}

function irscp() {
    sshpass -p welcome scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $@
}

function gra() {
    username=$1
    git remote add $1 https://github.com/pure-forks/$1-iridium.git
    git fetch $1
}

function cp2c() {
    CLUSTER=$1
    if [ -z "$CLUSTER" ]; then
        echo "usage: key <CLUSTER>"
        exit 1
    fi

    CLUSTER_IP=$(nslookup irp222-c05 | grep Server | sed "s/Server:\s*//")

    PROFILES=(
        ".quiltrc"
        ".vimrc"
        ".bashrc"
    )

    # SSH key
    ssh-keygen -R ${CLUSTER}
    ssh-keygen -R ${CLUSTER_IP}
    ssh-copy-id -i ~/.ssh/id_rsa.pub ir@${CLUSTER}
    ssh-copy-id -i ~/.ssh/id_rsa.pub ir@${CLUSTER}h01

    # copy to initiator and leader FM
    for host in ${CLUSTER} ${CLUSTER}h01; do
        ssh ir@${host} "mkdir -p /home/ir/scripts/tmenninger"
        scp -r /scripts/profiles ir@${host}:/home/ir/scripts/tmenninger

        for profile in ${PROFILES[@]}; do
            scp ~/${profile} ir@${host}:/home/ir
            ssh ir@${host} "sudo bash -c \"cp /home/ir/${profile} /root/\""
        done
    done

    # copy scripts to all blades
    ssh ir@${CLUSTER}    "exec.py -na \"sudo bash -c \\\"scp -r sup:/home/ir/scripts/ /home/ir/\\\"\""
    ssh ir@${CLUSTER}                                   "scp -r /home/ir/scripts/ supr:/home/ir/"

    ssh ir@${CLUSTER}    "exec.py                      \"cd /      && sudo ln -sf /home/ir/scripts\""
    ssh ir@${CLUSTER}    "exec.py     \"sudo bash -c \\\"cd /root/ &&      ln -sf /scripts\\\"\""

    ssh ir@${CLUSTER}h01                                "cd /      && sudo ln -sf /home/ir/scripts"
    ssh ir@${CLUSTER}h01               "sudo bash -c   \"cd /root/ &&      ln -sf /scripts\""

    # do profiles
    for profile in ${PROFILES[@]}; do
        ssh ir@${CLUSTER} "exec.py \"sudo bash -c \\\"scp sup:/home/ir/${profile} /home/ir/\\\"\""
        ssh ir@${CLUSTER} "exec.py \"sudo bash -c \\\"ln -sf /home/ir/${profile} /root/${profile}\\\"\""
    done
}

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
