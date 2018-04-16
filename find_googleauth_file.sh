#!/bin/bash
user_list=($(awk -F':' '$3 > 499' /etc/passwd))
for i in ${user_list[@]}
do
	find /home/$i/.google_authenticator -exec cp {} /destination/data/ \;
done
