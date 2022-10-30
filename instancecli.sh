#!/bin/bash
AWS_REGION="us-west-2"
VPC_NAME="My_VPC"
VPC_CIDR="192.168.0.0/16"
SUBNET_PUBLIC_CIDR="192.168.0.0/24"
SUBNET_PUBLIC_AZ="us-west-2b"
SUBNET_PUBLIC_NAME="pub_subnet"
DESTINATION_CIDR_BLOCK="0.0.0.0/0"
SUBNET_PRIVATE_CIDR="192.168.1.0/24"
PROTOCOL="tcp"
PORT_FOR_SSH="22"
PORT_FOR_HTTP="80"
PORT_FOR_HTTPS="443"
##PORT_FOR_WEB="8080"
SUBNET_PRIVATE_AZ="us-west-2b"
SUBNET_PRIVATE_NAME="pvt_subnet"
SEC_NAME="my_sec"
INSTANCE_NAME="myinstance"
IMAGE_ID="ami-017fecd1353bcc96e"
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
  --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=Oregon-Vpc}]' \
  --output text \
  --region $AWS_REGION)
echo Vpc-Id = $VPC_ID


# Create Public Subnet
ec2public=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC_CIDR \
  --availability-zone $SUBNET_PUBLIC_AZ \
  --query 'Subnet.Subnet_Id' \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet}]' \
  --output text \
  --region $AWS_REGION)
echo Subnet_id = $ec2public



# Create Private Subnet
ec2private=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE_CIDR \
  --availability-zone $SUBNET_PRIVATE_AZ \
  --query 'Subnet.SubnetId' \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet}]' \
  --output text \
  --region $AWS_REGION)
echo Private-Subnet-Id = $ec2private

# Create Internet gateway
Gateway_id=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Oregon-igw}]' \
  --output text \
  --region $AWS_REGION)
echo Internet_gateway_id = $Gateway_id


# Attach internetgateway to vpc 
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $Gateway_id \
  --region $AWS_REGION
  echo gateway_id = $Gateway_id

# Create Route Table
Table_route=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --region $AWS_REGION \
  --query 'RouteTable.RouteTableId' \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=Jenkins-Rt}]" \
  --output text) 
  echo $Routetable_id = $Table_route

  #create route to routetable
  Route_routetable=$(aws ec2 create-route \
   --route-table-id $Table_route \
   --destination-cidr-block $DESTINATION_CIDR_BLOCK \
   --gateway-id $Gateway_id \
   --region $AWS_REGION \
    --output text) 
echo Route_id = $Table_route

# Associate Public Subnet with Route Table
Route_id=$(aws ec2 associate-route-table  \
  --subnet-id $ec2private \
  --route-table-id $Table_route \
  --output text \
  --region $AWS_REGION)
echo pub_route_id = $Route_id



# creating security group
my_security=$(aws ec2 create-security-group \
--group-name "MySecurityGroup" \
--description "My security group" \
--vpc-id $VPC_ID \
--region $AWS_REGION \
--output text)
echo security = $my_security


# inbound rules
Bitturule=$(aws ec2 authorize-security-group-ingress \
    --group-id  $my_security \
    --protocol $PROTOCOL \
    --port $PORT_FOR_SSH \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Open_22}]' \
    --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
    --cidr $DESTINATION_CIDR_BLOCK \
    --output text)
    echo rule = $Bitturule

 # inbound rules
  Bitturule_1=$(aws ec2 authorize-security-group-ingress \
    --group-id  $my_security \
    --protocol $PROTOCOL \
    --port $PORT_FOR_HTTP \
    --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Open_80}]' \
    --cidr $DESTINATION_CIDR_BLOCK \
    --output text)
    echo rule = $Bitturule_1

    


    # inbound rules
     sg_rule_3=$(aws ec2 authorize-security-group-ingress \
    --group-id  $my_security \
    --protocol $PROTOCOL \
    --port $PORT_FOR_HTTPS \
    --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Open_443}]' \
    --cidr $DESTINATION_CIDR_BLOCK \
    --output text)
     echo rule3 = $sg_rule_3
     
  

   #creating instance
  Instance_Id=$(aws ec2 run-instances \
  --image-id $IMAGE_ID \
  --count "1" \
  --security-group-ids $my_security \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Jenkins-Cli-Instance}]' \
  --subnet-id $ec2private \
  --instance-type $TYPE \
  --region $AWS_REGION \
  --key-name $KEY_NAME \
  --associate-public-ip-address \
  --query 'Instances[0].InstanceId' \
  --output text) 
  echo instance = $Instance_Id
 






