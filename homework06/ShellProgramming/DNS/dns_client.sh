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
        # install pure-ftpd
        sudo apt-get install resolvconf
        if [[ $? -ne 0 ]];then
                echo "Installation of resolvconf failed:("
        else
                echo "resolvconf is successfully installed:)"
        fi
}

: <<'COMMENT'
        function: modify the config file
COMMENT
function modify_conf {
        cat>>{$head_conf}<<EOF
        search cuc.edu.cn
        nameserver 192.168.57.1
        EOF

        sudo resolvconf -u
}

sys_check
modify_conf
