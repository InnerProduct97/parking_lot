#!/bin/bash

# Set your desired region, instance details, IAM role, and security group
region="us-east-1"
instance_type="t2.micro"
ami_id="ami-0dba2cb6798deb6d8" # Ubuntu 20.04 LTS
iam_role="cli-created"
key_name="cli-created-ec2"
security_group_id="sg-0eefe4766f7e306ec"
instance_name="WebServer"

# Download the PEM key
echo "Downloading PEM key..."
aws ec2 create-key-pair \
  --region $region \
  --key-name $key_name \
  --query 'KeyMaterial' \
  --output text > $key_name.pem

# Create the EC2 instance
echo "Creating EC2 instance..."
instance_id=$(aws ec2 run-instances \
  --region $region \
  --image-id $ami_id \
  --instance-type $instance_type \
  --key-name $key_name \
  --security-group-ids $security_group_id \
  --iam-instance-profile Name=$iam_role \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$instance_name'}]' \
  --output text \
  --query 'Instances[0].InstanceId')

echo "EC2 instance created with ID: $instance_id"

echo "PEM key downloaded to $key_name.pem"
chmod 400 $key_name.pem

# Wait for the instance to start up
echo "Waiting for instance to start up..."
aws ec2 wait instance-status-ok --instance-ids $instance_id --region $region

# Get the public IP address of the instance
public_ip=$(aws ec2 describe-instances \
  --region $region \
  --instance-ids $instance_id \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Instance IP address: $public_ip"

# Copy the deploy script to the instance
echo "Copying deploy script to instance..."
scp -i $key_name.pem $deploy_script ubuntu@$public_ip:~/

# Run the deploy script on the instance
echo "Running deploy script on instance..."
ssh -i $key_name.pem ubuntu@$public_ip "./$deploy_script"