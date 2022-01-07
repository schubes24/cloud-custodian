#!/bin/bash
#
# This script invokes the Cloud Custodian iam-user-tagged-resources-audit.yml
# policy then generates a consolidated report of AWS resources 
# that match the given IAM user specified by the Owner tag.
#
# To change the owner, find/replace the IAM user in
# iam-user-tagged-resource.audit.yml. 
#
# By default, the policy is invoked in us-east-1.
# The region can be modified by changing the value of variable 'REGION'.
#
# Upon completion, the consolidated report can be found here: 
# /home/ubuntu/cloudcustodian/policies/report.txt
#

# Variables
RESOURCE=ebs,ebs-snapshot,security-group,s3,ami,dynamodb-table,dynamodb-stream,dynamodb-backup,elasticsearch,elb,eni,lambda,lambda-layer,rds,s3,sqs,sns,cfn,workspaces-directory,directory,waf
REGIONS="--region us-east-1 --region us-east-2 --region us-west-1 --region us-west-2 --region sa-east-1 --region eu-central-1 --region eu-north-1 --region eu-west-1 --region eu-west-2 --region eu-west-3  --region ca-central-1  --region ap-northeast-1 --region ap-northeast-2 --region ap-northeast-3 --region ap-southeast-1 --region ap-southeast-2 --region ap-south-1"
REGION="--region all"
CUSTODIAN_POLICY="/home/schubes24/_git_repos/cloudcustodian/resources-audit.yaml"
CUSTODIAN_OUTPUT_DIRECTORY="/home/schubes24/_git_repos/cloudcustodian/output"
CUSTODIAN_REPORT="/home/schubes24/_git_repos/cloudcustodian/report.csv"

# Activate c7n virtual environment
cd /home/ubuntu
source c7n_mailer/bin/activate

# Clear c7n cache
echo '------------------'
echo 'Clearing c7n cache '
echo '------------------'
rm /home/ubuntu/.cache/cloud-custodian.cache
echo '~/.cachecloud-custodian.cache cleared'

# Invoke c7n policy
echo '-------------------'
echo 'Invoking c7n policy'
echo '-------------------'
custodian run -s $CUSTODIAN_OUTPUT_DIRECTORY $CUSTODIAN_POLICY $REGION

# Generate c7n reports
echo '-------------------------------'
echo 'Generating report for resources'
echo '-------------------------------'

# Write ec2 report to file
echo 'ec2'
echo 'ec2' > $CUSTODIAN_REPORT
custodian report -s $CUSTODIAN_OUTPUT_DIRECTORY -t ec2 $CUSTODIAN_POLICY $REGIONS --format csv >> $CUSTODIAN_REPORT
echo ' ' >> $CUSTODIAN_REPORT

# Append more resources to file
for i in $(echo $RESOURCE | sed "s/,/ /g")
do
    # Loop through the RESOURCE list 
    echo $i  
    echo $i >> $CUSTODIAN_REPORT
    custodian report -s $CUSTODIAN_OUTPUT_DIRECTORY -t $i $CUSTODIAN_POLICY $REGIONS --format csv >> $CUSTODIAN_REPORT
    echo ' ' >> $CUSTODIAN_REPORT
done

echo ''
echo '-------------------------------'
echo 'Report'
echo '-------------------------------'
more $CUSTODIAN_REPORT

echo ''
echo 'Report completed!                                  '
echo 'See /home/schubes24/_git_repos/cloudcustodian/report.txt'