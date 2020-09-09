#!/bin/bash

loadbalancer_monitoring() {
    #Threshold Values
    unhealthyhosts_threshold="1"
    threshold_4xx="2"
    threshold_5xx="2"
    threshold_5xx_lb="2"

    template_string1="Critical | AWS INF | ELB | $1"
    template_string2="breached Upper Threshold"
    if [[ "$3" == "classic" ]]
    then
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | UnHealthyHostCount ${template_string2}" --alarm-description "${template_string1} | UnHealthyHostCount ${template_string2}" --metric-name UnHealthyHostCount --namespace AWS/ELB --statistic Average --period 900 --threshold ${unhealthyhosts_threshold} --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | HTTPCode_Backend_4XX ${template_string2}" --alarm-description "${template_string1} | HTTPCode_Backend_4XX ${template_string2}" --metric-name HTTPCode_Backend_4XX --namespace AWS/ELB --statistic Sum --period 900 --threshold ${threshold_4xx} --comparison-operator GreaterThanThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | HTTPCode_Backend_5XX ${template_string2}" --alarm-description "${template_string1} | HTTPCode_Backend_5XX ${template_string2}" --metric-name HTTPCode_Backend_5XX --namespace AWS/ELB --statistic Sum --period 900 --threshold ${threshold_5xx} --comparison-operator GreaterThanThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | HTTPCode_ELB_5XX ${template_string2}" --alarm-description "${template_string1} | HTTPCode_ELB_5XX ${template_string2}" --metric-name HTTPCode_ELB_5XX --namespace AWS/ELB --statistic Sum --period 900 --threshold ${threshold_5xx_lb} --comparison-operator GreaterThanThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
    elif [[ "$3" == "application" ]]
    then
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | UnHealthyHostCount ${template_string2}" --alarm-description "${template_string1} | UnHealthyHostCount ${template_string2}" --metric-name UnHealthyHostCount --namespace AWS/ApplicationELB --statistic Average --period 900 --threshold ${unhealthyhosts_threshold} --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | HTTPCode_Target_4XX_Count ${template_string2}" --alarm-description "${template_string1} | HTTPCode_Target_4XX_Count ${template_string2}" --metric-name HTTPCode_Target_4XX_Count --namespace AWS/ApplicationELB --statistic Sum --period 900 --threshold ${threshold_4xx} --comparison-operator GreaterThanThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | HTTPCode_Target_5XX_Count ${template_string2}" --alarm-description "${template_string1} | HTTPCode_Target_5XX_Count ${template_string2}" --metric-name HTTPCode_Target_5XX_Count --namespace AWS/ApplicationELB --statistic Sum --period 900 --threshold ${threshold_5xx} --comparison-operator GreaterThanThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
        aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | HTTPCode_ELB_5XX_Count ${template_string2}" --alarm-description "${template_string1} | HTTPCode_ELB_5XX_Count ${template_string2}" --metric-name HTTPCode_ELB_5XX_Count --namespace AWS/ApplicationELB --statistic Sum --period 900 --threshold ${threshold_5xx_lb} --comparison-operator GreaterThanThreshold  --dimensions "Name= LoadBalancerName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Count --region ${region}
    else
        echo "Unknown Loadbalancer Type"
    fi
}

autoscaling_monitoring() {
    #Threshold Values
    cpu_utilisation="80"
    diskspace_utilisation="80"
    memory_utilisation="80"

    template_string1="Critical | AWS INF | EC2 | $1"
    template_string2="breached Upper Threshold"

    aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | CPUUtilization ${template_string2}" --alarm-description "${template_string1} | CPUUtilization ${template_string2}" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold ${cpu_utilisation} --comparison-operator GreaterThanThreshold  --dimensions "Name=AutoScalingGroupName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Percent --region ${region}
    aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | MemoryUtilization ${template_string2}" --alarm-description "${template_string1} | MemoryUtilization ${template_string2}" --metric-name MemoryUtilization --namespace System/Linux --statistic Average --period 300 --threshold ${memory_utilisation} --comparison-operator GreaterThanThreshold  --dimensions "Name=AutoScalingGroupName,Value=$2" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Percent --region ${region}
    aws cloudwatch put-metric-alarm --alarm-name "${template_string1} | DiskSpaceUtilization ${template_string2}" --alarm-description "${template_string1} | DiskSpaceUtilization ${template_string2}" --metric-name DiskSpaceUtilization --namespace System/Linux --statistic Average --period 300 --threshold ${diskspace_utilisation} --comparison-operator GreaterThanThreshold  --dimensions "Name=AutoScalingGroupName,Value=$2" "Name=MountPath,Value=/" "Name=Filesystem,Value=/dev/nvme0n1p1" --evaluation-periods 1 --alarm-actions ${alarm_arns[@]} --unit Percent --region ${region}
}

main() {
    #ARN of SNS
    alarm_arns=("arn:aws:sns:us-east-1:123456789012:notify-mysns")
    environment_lists=("service1" "service2")
    region="us-east-1"

    #get details about the environments:
    for i in ${environment_lists[@]}
    do
        env_details=($(aws elasticbeanstalk describe-environment-resources --environment-name $i --query "EnvironmentResources.[EnvironmentName,AutoScalingGroups[*],LoadBalancers[*],Instances[*]]" --output text --region ${region}| tr '\n' ' '))
        autoscaling_monitoring $i ${env_details[1]}
        app_name=$(aws elasticbeanstalk describe-environments --environment-names $i --query "Environments[*].[ApplicationName]" --output text --region ${region})
        loadbalancer_type=$(aws elasticbeanstalk describe-configuration-settings --application-name ${app_name} --environment-name $i --query 'ConfigurationSettings[*].OptionSettings[?OptionName==`LoadBalancerType`].{type: Value}' --output text --region ${region})
        loadbalancer_monitoring $i ${env_details[2]} ${loadbalancer_type}
    done
}

main
