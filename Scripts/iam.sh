#!/bin/bash

# Set your desired region and role details
region="us-east-1"
role_name="cli-created"
policy_name="cli-created-policy"
description="Web Server IAM role Created with AWS CLI"
instance_profile_name="cli-created"
# Create the IAM role
echo "Creating IAM role..."
role_arn=$(aws iam create-role \
  --region $region \
  --role-name $role_name \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
  --description "$description" \
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
  --instance-profile-name $instance_profile_name \
  --output text \
  --query 'InstanceProfile.Arn')

echo "Instance profile created with ARN: $instance_profile_arn"

# Add the IAM role to the instance profile
echo "Adding IAM role to instance profile..."
aws iam add-role-to-instance-profile \
  --region $region \
  --instance-profile-name $instance_profile_name \
  --role-name $role_name

echo "IAM role added to instance profile"
