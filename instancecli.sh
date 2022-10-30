#!/bin/bash
#.......................................................
REGION="us-west-2"
VPC_CIDR="10.10.0.0/16"
PUB_SUBNET="10.10.0.0/24"
SUBNET_AZ_ZONES="us-west-2a"
DESTINATION_CIDRBLOCK="0.0.0.0/0"
GROUP_NAME="Jenkins-Sg"
##DESCRIPTION="forcli"
PROTOCOL="tcp"
###PORT_FOR_SSH="22"
##PORT_FOR_HTTP="80"
##PORT_FOR_HTTPS="443"
##PORT_WEB_SERVERS_WORKING="8080"
IMAGE_ID="ami-017fecd1353bcc96e"
INSTANCE_TYPE="t2.micro"
KEY_PAIR_NAME="key"
INSTANCES_COUNT="1"
#creating all new
#creating vpc
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=MyVpc}]' \
  --region $REGION \
  --query 'Vpc.VpcId' \
  --output text)
echo VPC_ID = "$VPC_ID"

#creating a pub subnet
SUBNET=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PUB_SUBNET \
  --availability-zone $SUBNET_AZ_ZONES \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Pub_Subnet}]' \
  --query 'Subnet.SubnetId' \
  --region $REGION \
  --output text) 
echo SUBNET = "$SUBNET"

#creating internetgateway
MY_INTERNETGATEWAY=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=internet-gateway}]' \
  --region $REGION \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)
echo GatewayId = $MY_INTERNETGATEWAY


#attaching internetgateway to vpc
aws ec2 attach-internet-gateway \
  --internet-gateway-id $MY_INTERNETGATEWAY \
  --vpc-id $VPC_ID \
  --region $REGION 
echo Vpc_Id = $VPC_ID
echo GatewayId = $MY_INTERNETGATEWAY



#creating route tables
RouteTable_Id=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --region $REGION \
  --output text) 
echo RouteTable = "$RouteTable_Id"

#creating route to associate to routetable
 aws ec2 create-route \
  --route-table-id $RouteTable_Id \
  --destination-cidr-block $DESTINATION_CIDRBLOCK \
  --gateway-id $MY_INTERNETGATEWAY \
  --region $REGION \
  --output text
echo Routetableid = $RouteTable_Id


#attching route to subnet
ATTACHING_ROUTE_TO_SUBNET=$(aws ec2 associate-route-table \
  --route-table-id $RouteTable_Id \
  --subnet-id $SUBNET \
  --query 'AssociationId' \
  --region $REGION \
  --output text)
echo RouteTable_Id = $RouteTable_Id


#creating_security_group
Security_GroupId=$(aws ec2 create-security-group \
  --group-name $GROUP_NAME \
   --vpc-id $VPC_ID \
  --description "forcli" \
  --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=Jenkins_Security_Group}]' \
  --region $REGION \
  --query 'GroupId' \
  --output text)
 echo Security-GroupId = $Security_GroupId

 #inbound_rules_for_security_group port_22
forssh=$(aws ec2 authorize-security-group-ingress \
    --group-id $Security_GroupId \
    --region $REGION \
    --protocol $PROTOCOL \
    --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
    --port "22" \
    --cidr $DESTINATION_CIDRBLOCK \
    --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Open_Ssh}]' \
    --output text)
echo creating_inbound = $forssh


 #inbound_rules_for_security_group port_80
 creating_inbound_rules80=$(aws ec2 authorize-security-group-ingress \
  --group-id $Security_GroupId \
  --region $REGION \
  --protocol $PROTOCOL \
  --port "80" \
  --cidr $DESTINATION_CIDRBLOCK \
  --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
  --output text)
echo creating_80 = $creating_inbound_rules80


 #inbound_rules_for_security_group port_443
 creating_inbound_rules_443=$(aws ec2 authorize-security-group-ingress \
  --group-id $Security_GroupId \
  --region $REGION \
  --protocol $PROTOCOL \
  --port "443" \
  --cidr $DESTINATION_CIDRBLOCK \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Open_443}]' \
  --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
  --output text)
echo creating_443 = $creating_inbound_rules_443


 #inbound_rules_for_security_group port_8080
 creating_inbound_rules_8080=$(aws ec2 authorize-security-group-ingress \
  --group-id $Security_GroupId \
  --region $REGION \
  --protocol $PROTOCOL \
  --port "8080" \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Open_8080}]' \
  --cidr $DESTINATION_CIDRBLOCK \
  --query 'SecurityGroupRules[0].SecurityGroupRuleId' \
  --output text)
echo inbound = $creating_inbound_rules_8080

#creating a instance on ubuntu22
CREATING_INSTANCE=$(aws ec2 run-instances \
  --image-id $IMAGE_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_PAIR_NAME \
  --region $REGION \
  --subnet-id $SUBNET \
  --count $INSTANCES_COUNT \
  --associate-public-ip-address
  --query 'Instances[0].InstanceId' \
  --output text)
 echo instance = $CREATING_INSTANCE




















 









