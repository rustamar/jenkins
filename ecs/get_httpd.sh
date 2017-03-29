#!/bin/sh

instance_id=$(aws autoscaling describe-auto-scaling-instances --output=json |grep "InstanceId" | awk -F "\"" '{print $4}')
aws ec2 describe-instances --instance-ids ${instance_id} | grep PublicIpAddress | awk -F " " '{print $4}'
