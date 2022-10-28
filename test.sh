#!/bin/bash
AWS_REGION="us-west-2"
VPC_NAME="My_VPC"
VPC_CIDR="10.0.0.0/16"
SUBNET_PUBLIC_CIDR="10.0.0.0/24"
SUBNET_PUBLIC_AZ="us-west-2b"
SUBNET_PUBLIC_NAME= "pub_subnet"
SUBNET_PRIVATE_CIDR="10.0.1.0/24"
SUBNET_PRIVATE_AZ="us-west-2b"
SUBNET_PRIVATE_NAME=  "pvt_subnet"
SEC_NAME= "my_sec"
INSTANCE_NAME="myinstance"
IMAGE_ID="ami-0d593311db5abb72b"
TYPE="t2.micro"
KEY_NAME="key"


#
#==============================================================================
#   DO NOT MODIFY CODE BELOW
#==============================================================================
#
# Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.VpcId' \
  --tag-specification ResourceType=vpc,Tags=[{Key=Name,Value=Oregon-Vpc}] \
  --output text \
  --region $AWS_REGION)
echo Vpc-Id = $VPC_ID


# Create Public Subnet
SUBNET_PUBLIC_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC_CIDR \
  --availability-zone $SUBNET_PUBLIC_AZ \
  --query 'Subnet.Subnet_Id' \
  --tag-specifications ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet}] \
  --output text \
  --region $AWS_REGION)
echo Public-Subnet-Id = $SUBNET_PUBLIC_ID 



# Create Private Subnet
SUBNET_PRIVATE_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE_CIDR \
  --availability-zone $SUBNET_PRIVATE_AZ \
  --query 'Subnet.SubnetId' \
  --tag-specifications ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet}] \
  --output text \
  --region $AWS_REGION)
echo Private-Subnet-Id = $SUBNET_PRIVATE_ID


# Create Internet gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --tag-specifications ResourceType=internet-gateway,Tags=[{Key=Name,Value=Oregon-igw}] \
  --output text \
  --region $AWS_REGION)
echo Internet-Gateway-Id = $IGW_ID


# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."
