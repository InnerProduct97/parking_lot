#!/bin/bash

# Set your desired region and role details
region="us-east-1"
role_name="RekognitionFullAccess"
policy_name="RekognitionFullAccess-policy"
iam_description="Web Server IAM role Created with AWS CLI"

# Set your desired region, instance details, IAM role, and security group
instance_type="t2.micro"
ami_id="ami-0dba2cb6798deb6d8" # Ubuntu 20.04 LTS
key_name="WebServer_Security"
instance_name="WebServer"
deploy_script="deploy.sh"

# Set your desired region and security group details
security_group_name="web_server_sg"
description="Allows SSH, HTTP and HTTPS"


# Create the IAM role
echo "Creating IAM role..."
role_arn=$(aws iam create-role \
  --region $region \
  --role-name $role_name \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
  --description "$iam_description" \
  --output text \
  --query 'Role.Arn')

echo "IAM role created with ARN: $role_arn"

# Create the IAM policy
echo "Creating IAM policy..."
policy_arn=$(aws iam create-policy \
  --region $region \
  --policy-name $policy_name \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"rekognition:*","Resource":"*"}]}' \
  --output text \
  --query 'Policy.Arn')

echo "IAM policy created with ARN: $policy_arn"

# Attach the policy to the role
echo "Attaching policy to IAM role..."
aws iam attach-role-policy \
  --region $region \
  --role-name $role_name \
  --policy-arn $policy_arn

echo "Policy attached to IAM role"

# Create the instance profile
echo "Creating instance profile..."
instance_profile_arn=$(aws iam create-instance-profile \
  --region $region \
  --instance-profile-name $role_name \
  --output text \
  --query 'InstanceProfile.Arn')

echo "Instance profile created with ARN: $instance_profile_arn"

# Add the IAM role to the instance profile
echo "Adding IAM role to instance profile..."
aws iam add-role-to-instance-profile \
  --region $region \
  --instance-profile-name $role_name \
  --role-name $role_name

echo "IAM role added to instance profile"

# Create the security group
echo "Creating security group..."
security_group_id=$(aws ec2 create-security-group \
  --region $region \
  --group-name $security_group_name \
  --description "$description" \
  --output text \
  --query 'GroupId')

echo "Security group created with ID: $security_group_id"

# Allow SSH access to the security group
echo "Allowing SSH access to security group..."
aws ec2 authorize-security-group-ingress \
  --region $region \
  --group-id $security_group_id \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Allow HTTPS access to the security group
echo "Allowing HTTPS access to security group..."
aws ec2 authorize-security-group-ingress \
  --region $region \
  --group-id $security_group_id \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Allow HTTP access to the security group
echo "Allowing HTTP access to security group..."
aws ec2 authorize-security-group-ingress \
  --region $region \
  --group-id $security_group_id \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

echo "Security group created with ID: $security_group_id"

# EC2 instance
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
  --iam-instance-profile Name=$role_name \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$instance_name'}]' \
  --output text \
  --query 'Instances[0].InstanceId')

echo "EC2 instance created with ID: $instance_id"

echo "PEM key downloaded to $key_name.pem"
chmod 400 $key_name.pem

# Wait for the instance to start up
echo "Waiting for instance to start up..."
aws ec2 wait instance-status-ok --instance-ids $instance_id --region $region


# Allocate an Elastic IP
echo "Allocating Elastic IP..."
allocation_id=$(aws ec2 allocate-address \
  --region $region \
  --domain vpc \
  --output text \
  --query 'AllocationId')

echo "Elastic IP allocated with ID: $allocation_id"

# Associate the Elastic IP with the instance
echo "Associating Elastic IP with instance..."
aws ec2 associate-address \
  --region $region \
  --instance-id $instance_id \
  --allocation-id $allocation

echo "Elastic IP address created and associated with instance"

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