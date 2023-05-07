#!/bin/bash

# Set your desired region and security group details
region="us-east-1"
security_group_name="web_server_sg"
description="Allows SSH, HTTP and HTTPS"

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