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
        sudo apt-get install pure-ftpd
        if [[ $? -ne 0 ]];then
                echo "Installation of pure-ftpd failed:("
        else
                echo "pure-ftpd is successfully installed:)"
        fi
}

: <<'COMMENT'
        function: configure an FTP server that provides anonymous access
COMMENT
function allow_anony {
        # modify the config file to allow anonymous login
        echo "no" > /etc/pure-ftpd/conf/NoAnonymous
        # create user group and anonymous user
        grep -E "^$group" /etc/group >& /dev/null
        if [[ $? -ne 0 ]];then
                sudo groupadd $group
                echo "$group is successfully added:)"
        else
                echo "Skip group-adding, $group already exists:)"
        fi
        grep -E "^{$ano_user}" /etc/passwd >& /dev/null
        if [[ $? -ne 0 ]];then
                sudo useradd -g {$group} {$ano_user}
                echo "{$ano_user} is successfully added:)"
        else
                echo "Skip user-adding, {$ano_user} already exists:)"
        fi
        # create anonymous root file
        if [[ ! -d "$ano_root_path" ]];then
                sudo mkdir {$ano_root_path}
                echo "Directory {$ano_root_path} is successfully created:)"
        else
                echo "Skip directory creation, {$ano_root_path} already exists:)"
        fi
        # add read-only directory
        if [[ ! -d "$ano_subdir" ]];then
                sudo mkdir {$ano_subdir}
                sudo touch {$ano_subdir}/hello.txt
                echo "Hello World:)" > {$ano_subdir}/hello.txt
                echo "Read-only directory for anonymous visits is successfully created:)"
        else
                echo "Skip subdirectory creation, {$ano_subdir} already exists:)"
        fi

        sudo chown -R {$ano_user}:{$ano_group} {$ano_root_path}
        sudo chmod -R u-w-x g-w-x o-w-x {$ano_subdir}
}

: <<'COMMENT'
        function: configure a virtual user that satisfies the restrictions of homework_06
COMMENT
function add_user {
        # create user to manage virtual users
        grep -E "^{$guest_user}" /etc/passwd >& /dev/null
        if [[ $? -ne 0 ]];then
                # prohibit shell-login
                sudo useradd {$guest_user} -g {$group} -s /sbin/nologin
                echo "{$guest_user} is successfully added:)"
        else
                echo "Skip user-adding, {$guest_user} already exists:)"
        fi
        # create the root file of user1(virtual)
        if [[ ! -d {$guest_root_path} ]];then
                sudo mkdir -p {$guest_root_path}
                echo "Directory {$guest_root_path} is successfully created:)"
        else
                echo "Skip directory creation, {$guest_root_path} already exists:)"
        fi
        # create the rwx_allowed subdirectory
        if [[ ! -d {$guest_subdir} ]];then
                sudo mkdir {$guest_subdir}
                sudo touch {$guest_subdir}/rev.txt
                echo "This file is revisible." > {$guest_subdir}/rev.txt
                echo "rwx allowed directory {$guest_subdir} is successfully created:)"
        else
                echo "Skip subdirectory creation, {$guest_subdir} already exists:)"
        fi

        sudo chown -R {$guest_user}:{$group} {$guest_root_path}
        # succeed the priviledges from anonymous user
        sudo cp -r {$ano_subdir} {$guest_root_path}
        sudo chown -R {$ano_user}:{$group} {$ano_subdir}
        if [[ $? -ne 0 ]];then
                echo "Priviledge succession failed:("
                exit
        else
                echo "Priviledges successfully succeeded:)"
        fi
        # create virtual user==>user1
        sudo pure-pw useradd {$vuser} -u {$guest_user} -g {$group} -d {$guest_root_path}
        sudo pure-pw mkdb
        # enable authentication of virtual users
        cd /etc/pure-ftpd/auth/
        sudo ln -s ../conf/PureDB 60puredb
}

sys_check
allow_anony
add_user
sudo systemctl restart pure-ftpd