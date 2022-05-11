#!/bin/bash -xe

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

systemctl stop docker
rm -rf /var/lib/docker
systemctl start docker
