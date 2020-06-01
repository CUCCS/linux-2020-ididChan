#!/bin/bash

source ./conf.sh

: <<'COMMENT'
        function: refresh the system
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
        # install isc-dhcp-server
        sudo apt-get install isc-dhcp-server
        if [[ $? -ne 0 ]];then
                echo "Installation of isc-dhcp-server failed:("
                exit
        else
                echo "isc-dhcp-server is successfully installed:)"
        fi
}

: <<'COMMENT'
        function: configure the netplan
COMMENT
function conf_netplan {
        cat>>{$net_conf}<<EOF
                {$card}:
                        dhcp4: no
                        addresses: ["$address"]
        EOF
        sudo netplan apply
}

: <<'COMMENT'
        function: select the interface
COMMENT
function select_interface {
        sed -i -e "/INTERFACESv4=/s/^[#]//g;/INTERFACESv4=/s/\=.*/=\"${card}\"/g" "$initscript"
        if [[ $? -ne 0 ]];then
                echo "Selection of interface failed:("
                exit
        else
                echo "Interface $card is successfully selected:)"
        fi
}

: <<'COMMENT'
        function: configure the subnet
COMMENT
function conf_subnet {
        cat>>{$conf_file}<<EOF
        subnet 192.168.57.0 netmask 255.255.255.0 {
                range ${ip_low} ${ip_high};
                option routers          ${op_router};
                option subnet-mask      ${op_mask};
                option broadcast-address        ${op_broadcast};
                default-lease-time ${def_lstime};
                max-lease-time ${mx_lstime};
        }
        EOF

        sudo systemctl restart isc-dhcp-server
}

sys_check
conf_netplan
select_interface
con_subnet