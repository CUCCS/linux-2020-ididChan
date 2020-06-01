#!/bin/bash

source ./conf.sh

: <<'COMMENT'
        function: update&upgrade the system
COMMENT
function sys_check {
        # update
        sudo apt-get update
        if [[ $? -ne 0 ]];then
                echo "Update failed:("
                exit
        else
                echo "Successfully updated:)"
        fi
        # upgrade
        sudo apt-get upgrade
        if [[ $? -ne 0 ]];then
                echo "Upgrade failed:("
                exit
        else
                echo "Successfully upgraded:)"
        fi
        # install samba
        sudo apt-get install samba
        if [[ $? -ne 0 ]];then
                echo "Installation of samba failed:("
                exit
        else
                echo "samba is successfully installed:)"
        fi
}

: <<'COMMENT'
        function: create user, group and directory
COMMENT
function prepare {
        sudo useradd -M -s /sbin/nologin $user
        if [[ $? -ne 0 ]];then
                echo "Creation of $user failed:("
                exit
        else
                echo "$user is successfully created:)"
        fi
        sudo passwd $user
        sudo smbpasswd -a $user
        if [[ $? -ne 0 ]];then
                echo "enable $user failed:("
                exit
        else
                echo "$user is successfully enabled for samba:)"
        fi
        sudo groupadd $group
        if [[ $? -ne 0 ]];then
                echo "Creation of $group failed:("
                exit
        else
                echo "$group is successfully created:)"
        fi
        sudo usermod -g $group $user

        sudo mkdir -p $path_share
        if [[ $? -ne 0 ]];then
                echo "Creation of anonymous directory failed:("
                exit
        else
                echo "Directory for anonymous visit is successfully created:)"
        fi
        sudo mkdir -p $path_guest
        if [[ $? -ne 0 ]];then
                echo "Creation of assigned directory failed:("
                exit
        else
                echo "Directory for assigned visit is successfully created:)"
        fi
        sudo chown -R {$user}:{$group} {$path_guest}
}

: <<'COMMENT'
        function: cofigure samba
COMMENT
function modify_config {
        cat>>{$conf}<<EOF
        [share]
                path = /home/samba/share
                guest ok = yes
                browseable = yes
                writeable = yes

        [guest]
                path = /home/samba/guest
                read only = no
                guest ok = no
                force create mode = 0660
                force directory mode = 2770
                force user = sambauser
                force group = sambagroup
        EOF
        sudo systemctl restart smbd
}

syscheck
prepare
modify_config