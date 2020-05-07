#!/bin/bash

: <<'COMMENT'
        function:统计访问来源主机TOP 100和分别对应出现的总次数
        params:
                $1:数据文件
COMMENT
function host_top100 {
        awk 'BEGIN{printf "统计访问来源主机TOP-100和对应出现的总次数:\n"}{print $1}' $1 | sort | uniq -c | sort -nr | head -n 100
}

: <<'COMMENT'
        function:统计访问来源主机TOP 100 IP和分别对应出现的总次数
        params:
                $1:数据文件
COMMENT
function host_ip_top100 {
        awk 'BEGIN{printf "访问来源主机TOP-100IP和分别对应出现的总次数:\n"}{if($1~/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/){print $1}}' $1 | sort | uniq -c | sort -nr | head -n 100
}

: <<'COMMENT'
        function:统计最频繁被访问的URL TOP 100
        params:
                $1:数据文件
COMMENT
function url_top100 {
        awk 'BEGIN{printf "最频繁被访问的URL TOP-100:\n"}{print $5}' $1 | sort | uniq -c | sort -nr | head -n 100
}

: <<'COMMENT'
        function:统计不同响应状态码的出现次数和对应百分比
        params:
                $1:数据文件
COMMENT
function response_calc {
        awk 'BEGIN{sum=-1;printf "不同响应状态码的出现次数和对应百分比:\n"}{if($6!="response"){a[$6]++};sum++}END{for(i in a){printf "%s: %dtimes(%.4f%%)\n",i,a[i],a[i]*100/sum}}' $1
}

: <<'COMMENT'
        function:分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
        params:
                $1:数据文件
COMMENT
function response_4xx_calc {
        awk 'BEGIN{printf "403状态码对应的TOP 10 URL和对应出现的总次数:\n"}{if($6=="403"){print $5}}' $1 | sort | uniq -c | sort -nr | head -n 10
        awk 'BEGIN{printf "404状态码对应的TOP 10 URL和对应出现的总次数:\n"}{if($6=="404"){print $5}}' $1 | sort | uniq -c | sort -nr | head -n 10
}

: <<'COMMENT'
        function:给定URL输出TOP 100访问来源主机
        params:
                $1:数据文件
                $2:目标URL
COMMENT
function aimed_host_top100 {
        url=$2
        awk 'BEGIN{printf "%s的TOP 100访问来源主机:\n","'"$url"'"}{if($5=="'"$url"'"){print $1}}' $1 | sort | uniq -c | sort -nr | head -n 100
}

: <<'COMMENT'
        function:帮助信息
COMMENT
function help {
echo "PARAMETERS HELP INFO:"
        echo ":=======================================================================================:"
        echo "-a [data_file]                         统计访问来源主机TOP 100和分别对应出现的总次数"
        echo "-b [data_file]                       统计访问来源主机TOP 100 IP和分别对应出现的总次数"
        echo "-c [data_file]                       统计最频繁被访问的URL TOP 100"
        echo "-d [data_file]                         统计不同响应状态码的出现次数和对应百分比"
        echo "-e [data_file]                       分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
        echo "-f [data_file][aimed_url]            给定URL输出TOP 100访问来源主机"
        echo "-h                                   帮助文档"
}

if [[ $# -lt 1 ]];then
        echo "error...more args are needed..."
        exit 1
else
        case $2 in
                -a)
                        host_top100 $1
                        exit 0;;
                -b)
                        host_ip_top100 $1
                        exit 0;;
                -c)
                        url_top100 $1
                        exit 0;;
                -d)
                        response_calc $1
                        exit 0;;
                -e)
                        response_4xx_calc $1
                        exit 0;;
                -f)
                        aimed_host_top100 $1 $3
                        exit 0;;
                -h)
                        help ;;
        esac
fi
