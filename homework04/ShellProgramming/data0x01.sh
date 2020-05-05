#!/bin/bash

: <<'COMMENT'
        function:统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
        params:
                $1:数据文件
COMMENT
function calc_age {
        awk -F "\t" 'BEGIN{a=0;b=0;c=0;sum=-1}{sum++;if($6<20){a++} else if($6>=20&&$6<=30){b++} else{c++}}END{printf "players aged in [0,20): %d(%.2f%%)\nplayers aged in [20,30]: %d(%.2f%%)\nplayers aged in (30,+inf): %d(%.2f%%)\n",a,a*100/sum,b,b*100/sum,c,c*100/sum}' $1
}

: <<'COMMENT'
        function:统计不同场上位置的球员数量、百分比
        params:
                $1:数据文件
COMMENT
function calc_pos {
        awk -F "\t" 'BEGIN{sum=-1}{sum++;a[$5]++}END{for(i in a){if(i!="Position"){printf "players of %s: %d(%.4f%%)\n",i,a[i],a[i]*100/sum}}}' $1
}

: <<'COMMENT'
        function:得到名字最长的球员与名字最短的球员
        params:
                $1:数据文件
COMMENT
function calc_name {
        len=$(awk -F "\t" '{if($9!="Player"){print length($9)}}' $1)

        min=100
        max=0

        for i in $len;do
                #echo $i
                if [[ $i -gt $max ]];then
                        max=$i
                fi
                if [[ $i -lt $min ]];then
                        min=$i
                fi
        done
        #echo $max
        #echo $min
        awk -F "\t" 'BEGIN{printf "player who has the longest name:\n"}{if(length($9)=="'"$max"'"){printf "%s\n",$9}}' $1
        awk -F "\t" 'BEGIN{printf "player who has the shortest name:\n"}{if(length($9)=="'"$min"'"){printf "%s\n",$9}}' $1

}

: <<'COMMENT'
        function:得到年龄最大的球员与年龄最小的球员
        params:
                $1:数据文件
COMMENT
function calc_extremum {
        ages=$(awk -F "\t" '{if($6!="Age"){print $6}}' $1)

        min=100
        max=0

        for i in $ages;do
                if [[ $i -gt $max ]];then
                        max=$i
                fi
                if [[ $i -lt $min ]];then
                        min=$i
                fi
        done

        awk -F "\t" 'BEGIN{printf "the oldest player:\n"}{if($6=="'"$max"'"){printf "%s: %d\n",$9,$6}}' $1
        awk -F "\t" 'BEGIN{printf "the youngest player:\n"}{if($6=="'"$min"'"){printf "%s: %d\n",$9,$6}}' $1
}

: <<'COMMENT'
        function:帮助信息
COMMENT
function help {
echo "PARAMETERS HELP INFO:"
        echo ":=======================================================================================:"
        echo "-a [data_file]      统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"
        echo "-b [data_file]    统计不同场上位置的球员数量、百分比"
        echo "-c [data_file]    得到名字最长的球员与名字最短的球员"
        echo "-d [data_file]    得到年龄最大的球员与年龄最小的球员"
        echo "-h                帮助文档"
}

if [[ $# -lt 1 ]];then
        echo "error...more args are needed..."
        exit 1
else
        case $2 in
                -a)
                        calc_age $1
                        exit 0;;
                -b)
                        calc_pos $1
                        exit 0;;
                -c)
                        calc_name $1
                        exit 0;;
                -d)
                        calc_extremum $1
                        exit 0;;
                -h)
                        help
                        exit 0;;
        esac
fi