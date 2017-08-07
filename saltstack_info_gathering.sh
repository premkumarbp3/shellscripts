#!/bin/bash
cdate=$(date +%Y%m%d)

output_gen()
{
        cp instances_connecting_${cdate}.txt state2_${cdate}.txt
        while read line2
        do
           keywor1=$(echo $line2 | awk -F'|' '{print $1}')
           sed -i -e  "/$keywor1/ s/$/|$line2/" state2_${cdate}.txt
        done < state1_${cdate}.txt

}


pkgfinder()
{
        while read line1
        do
                keywor=$(echo $line1| awk -F'|' '{print $1}')
                salt $keywor cmd.script salt://test.sh --out=txt | grep "stdout" | sed -e "s/ /|/g" -e "s/'//g" -e "s/}$//g" | awk -F':|' '{print $1$6}' &>> state1_${cdate}.txt
        done < instances_connecting_${cdate}.txt
}


formatter1()
{
while read line
do
        keywor=$(echo $line| awk -F'|' '{print $1}')
        sed -i -e  "/$keywor/ s/$/|$line/" instances_connecting_${cdate}.txt
done < aws_instances_list_${cdate}.txt
}

list_preparation()
{
        salt -G 'kernel:linux' test.ping --out txt | awk '$2 ~ /True/ {print $1}' | cut -d: -f1 >> instances_connecting_${cdate}.txt
}


aws_instance_list()
{
for i in eu-central-1 eu-west-1
do
        aws ec2 describe-instances --region $i --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==`Name`].Value,PrivateIpAddress,State.Name,Placement.AvailabilityZone]' --output text | paste - - -d"\t" | sed -e "s/\t/|/g" >>aws_instances_list_${cdate}.txt
done
}

aws_instance_list
list_preparation
formatter1
pkgfinder
output_gen
