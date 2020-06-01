#!/bin/bash

source ./conf.sh

expect -c "set timeout -1;
        spawn ssh-copy-id -i /home/idchannov/.ssh/id_rsa.pub $host;
        expect {
                *(yes/no)* {send -- yes\r;exp_continue;}
                *(password)* {send -- $password\r;exp_continue;}
                eof     {exit 0;}
        }";
