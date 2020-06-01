#!/bin/bash

source ./conf.sh

# install rpcbind
sudo apt-get install rpcbind
if [[ $? -ne 0 ]];then
        echo "Installation of rpcbind failed:("
        exit
else
        echo "rpcbind is successfully installed:)"
fi
#install nfs-common
sudo apt-get install nfs-common
if [[ $? -ne 0 ]];then
        echo "Installation of nfs-common failed:("
        exit
else
        echo "nfs-common is successfully installed:)"
fi
# create directory to mount the shared files
sudo mkdir -p $ro_path
if [[ $? -ne 0 ]];then
        echo "Creation of the directory(ro) failed:("
        exit
else
        echo "The read-only directory is successfully created:)"
fi
sudo mkdir -p $rw_path
if [[ $? -ne 0 ]];then
        echo "Creation of the directory(rw) failed:("
        exit
else
        echo "The read-and-write directory is successfully created:)"
fi
# mount the shared files
sudo mount -t nfs $server_ip:$read_only  $ro_path
if [[ $? -ne 0 ]];then
        echo "mount failed:("
        exit
else
        echo "The read-only files is successfully mounted:)"
fi
sudo mount -t nfs $server_ip:$read_and_write  $rw_path
if [[ $? -ne 0 ]];then
        echo "mount failed:("
        exit
else
        echo "The read-and-write directory is successfully mounted:)"
fi
