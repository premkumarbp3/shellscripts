#!/bin/bash
conf_file()
{
conf_filelist=($(apachectl -S | grep "port 80 namevhost" | grep -v "localhost" | awk -F'[(:]' '{print $2}' | paste -s -d" "))
con_len=${#conf_filelist[@]}
printf  "%s\t%s\t%s\t%s\t%s\n" "InstanceID" "PublicIP" "Availability Zone" "DomainName" "DNSEntry"
for((i=0;i<${con_len};i++));
do
        sitename=$(grep ServerName ${conf_filelist[${i}]} | sed -e "s/[ \s\t]ServerName//")
        alias_list=$(grep ServerAlias ${conf_filelist[${i}]} | sed -e "s/[ \s\t]ServerAlias//")
        newarray=($sitename ${alias_list[@]})
        alength=${#newarray[@]}
        for((j=0;j<${alength};j++));
        do
                output=$(nslookup ${newarray[${j}]} | grep  -A 1 canonical | grep Name | cut -f2)
                if [ ! -z $output ]
                then
                        printf "%-s\t%-s\t%-s\t%-s\t%s\n" "$instanceid" "$publicip" "$availabilityzone" "${newarray[${j}]}" "$output"
                fi
        done
done
}

main()
{
rpm -qa httpd* &> /dev/null
if [ $? -eq 0 ]
then
        conf_file
fi
}

instanceid=$(curl -s --proxy '' http://169.254.169.254/latest/meta-data/instance-id)
publicip=$(curl -s --proxy '' http://169.254.169.254/latest/meta-data/public-ipv4)
availabilityzone=$(curl -s --proxy '' http://169.254.169.254/latest/meta-data/placement/availability-zone)
main
