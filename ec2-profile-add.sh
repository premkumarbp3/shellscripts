#!/bin/bash
PROFILENAME="example"
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, IAMInstanceProfile.Arn]' --profile myprofile --region myregion --output text >> instance_details.txt
while read line
do
    role_profile=$(echo $line | awk '{print $2}')
    instance_id=$(echo $line | awk '{print $1}')
    if [ $role_profile == "None" ]; then
        echo "going to add the instance profile"
        aws ec2 associate-iam-instance-profile --iam-instance-profile Name="${PROFILENAME}" --instance-id ${instance_id}
    fi
done < ./instance_details.txt
