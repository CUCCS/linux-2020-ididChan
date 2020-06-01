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
# install nfs-kernel-server
sudo apt-get install nfs-kernel-server
if [[ $? -ne 0 ]];then
        echo "Installation of nfs-kernel-server failed:("
        exit
else
        echo "nfs-kernel-server is successfully installed:)"
fi
# modify the configuration of NFS
sudo echo "$read_only   $client_ip$info" >> /etc/exports
sudo echo "$read_and_write      $client_ip$info" >> /etc/exports
# restart the service
sudo systemctl restart rpcbind
sudo systemctl restart nfs-kernel-server
# the shared info
showmount -e $server_ip
