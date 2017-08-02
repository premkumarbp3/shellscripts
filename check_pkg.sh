#!/bin/bash
pkgs=( salt-minion sshd )
length=${#pkgs[@]}
centos_info()
{
        declare -a oput
        for((i=0;i<$length;i++))
        do
                rpm -q ${pkgs[$i]} &> /dev/null
                if [ $? -eq 0 ]
                then
                        chkconfig --list ${pkgs[$i]} &> /dev/null
                        if [ $? -eq 0 ];then
                                msg="${pkgs[$i]}|installed|enabled"
                        else
                                msg=="${pkgs[$i]}|installed|not-enabled"
                        fi
                else
                        msg="${pkgs[$i]}|not-installed|not-enabled"
                fi
                oput=(${oput[@]} "$msg")
        done
        echo ${oput[@]}| sed 's/ /|/'
}

ubuntu_info()
{
        declare -a arr
        arr=("0")
        R=$(runlevel | awk '{print $2}')
        for s in /etc/rc${R}.d/*
        do
           arr=(${arr[@]} "$(basename $s | grep '^S' | sed 's/S[0-9].//g')")
        done

        for((i=0;i<$length;i++))
        do
                 dpkg -l ${pkgs[$i]} &> /dev/null
                if [ $? -eq 0 ]
                then
                             echo ${arr[@]} | grep -o ${pkgs[$i]} > /dev/null
                             if [ $? -eq 0 ];then
                                msg="${pkgs[$i]}|installed|enabled"
                             else
                                 msg="${pkgs[$i]}|installed|not-enabled"
                             fi
                else
                        msg="${pkgs[$i]}|not-installed|not-enabled"
                fi
                oput=(${oput[@]} "$msg")
        done
        echo ${oput[@]}|sed 's/ /|/'
}

amazon_info()
{

        for((i=0;i<$length;i++))
        do
                rpm -q ${pkgs[$i]} &> /dev/null
                if [ $? -eq 0 ]
                then
                        chkconfig --list ${pkgs[$i]} &> /dev/null
                        if [ $? -eq 0 ];then
                                msg="${pkgs[$i]}|installed|enabled"
                        else
                                msg="${pkgs[$i]}|installed|not-enabled"
                        fi
                else
                        msg="${pkgs[$i]}|not-installed|not-enabled"
                fi
                oput=(${oput[@]} "$msg")
        done
        echo ${oput[@]}| sed 's/ /|/'
}

os_detection()
{
        if [ $(grep ubuntu /etc/os-release > /dev/null;echo $?) -eq 0 ]
        then
                ubuntu_info
        elif [ $(grep centos /etc/os-release > /dev/null;echo $?) -eq 0 ]
        then
                centos_info
        elif [ $(grep amzn /etc/os-release > /dev/null;echo $?) -eq 0 ]
        then
                amazon_info
        else
                echo "unknown"
                exit 1
        fi
}

os_detection
