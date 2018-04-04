#!/bin/bash
echo "+++++$HOSTNAME+++++"
user_list=($(awk -F':' '$1 !~ /nobody|ossec|ubuntu/ && $3 > 999 {print $1}' /etc/passwd))
for user in "${user_list[@]}"
do
	end_res=$(lastlog -u $user -t 90)
	if [ -z "$end_res" ]
	then
		lastlogin=$(lastlog -u $user | tail -n 1 | awk '{print $5" "$6" "$9}')
		echo -e "$user\t$lastlogin"
	fi
done
