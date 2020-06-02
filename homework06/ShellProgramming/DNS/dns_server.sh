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
        # install bind9
        sudo apt-get install bind9
        if [[ $? -ne 0 ]];then
                echo "Installation of bind9 failed:("
        else
                echo "bind9 is successfully installed:)"
        fi
}

: <<'COMMENT'
        function: modify config files
COMMENT
function modify_conf {
        # modify /etc/bind/named.conf.options
        sed -i '$d' {$op_conf}
        cat>>{$op_conf}<<EOF
                listen-on { 192.168.56.105; }; 
                allow-transfer { none; }; # disable zone transfers by default
                forwarders {
                        8.8.8.8;
                        8.8.4.4;
                };
        };
        EOF
        # modify /etc/bind/named.conf.local
        cat>>{$local_conf}<<EOF
        zone "cuc.edu.cn" {
                type master;
                file {$dest_conf};
        };
        EOF
        # generate config file
        sudo cp {$local_conf} {$dest_conf}
        if [[ $? -ne 0 ]];then
                echo "Generation of config file failed:("
                exit
        else
                echo "Config file is successfully generated:)"
        fi
        # modify /etc/bind/db.cuc.edu.cn
        cat>>{$dest_conf}<<EOF
                IN      NS      ns.cuc.edu.cn
        ns      IN      A       {$server_ip}
        {$site1}       IN      A       {$server_ip}
        {$site2}     IN      CNAME   {$site1}
        EOF

        sudo systemctl restart bind9
}

sys_check
modify_conf
