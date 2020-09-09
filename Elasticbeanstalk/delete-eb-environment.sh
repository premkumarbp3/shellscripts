#!/bin/bash
region="us-east-1"
account_id="123456789012"
extension=$(date "+%Y%m%d%H%M%S")
environmnet_list=("service1-dev" "service2-uat")


for environment_name in ${environmnet_list[@]}
do
  ebenv_info=($(aws elasticbeanstalk describe-environments --environment-names ${environment_name} --query "Environments[*].[ApplicationName, EnvironmentId]" --output text --region ${region}))
  aws elasticbeanstalk create-configuration-template --environment-id ${ebenv_info[1]} --application-name ${ebenv_info[0]} --template-name  ${environment_name}-final-backup-${extension} --region ${region}
  sleep 60
  aws s3 ls s3://elasticbeanstalk-${region}-${account_id}/resources/templates/${ebenv_info[0]}/${environment_name}-final-backup-${extension}
  if [ $? -eq "0" ]
  then
    echo "configuration backup completed going to delete ${environment_name} environment"
    aws elasticbeanstalk terminate-environment --environment-name ${environment_name} --region ${region}
    if [ $? -eq "0" ]
    then
        echo "environment ${environment_name} deleted successfully"
    fi
  else
    echo "configuration backup failed aborting deletion of ${environment_name} environment"
  fi
done
