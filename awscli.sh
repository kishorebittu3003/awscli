AWS_REGION="us-west-2"
VPC_NAME="My_VPC"
VPC_CIDR="10.0.0.0/16"
SUBNET_PUBLIC_CIDR="10.0.0.0/24"
SUBNET_PUBLIC_AZ="us-west-2b"
SUBNET_PUBLIC_NAME="pub_subnet"
SUBNET_PRIVATE_CIDR="10.0.1.0/24"
SUBNET_PRIVATE_AZ="us-west-2b"
SUBNET_PRIVATE_NAME="pvt_subnet"
SEC_NAME="my_sec"
INSTANCE_NAME="myinstance"
IMAGE_ID="ami-0d593311db5abb72b"
TYPE="t2.micro"
KEY_NAME="key"




CHECK_FREQUENCY=5
#
#==============================================================================
#   DO NOT MODIFY CODE BELOW
#==============================================================================
#
# Create VPC
echo "Creating VPC in preferred region..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.{VpcId:VpcId}' \
  --output text \
  --region $AWS_REGION)
echo "  VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."


# Create Public Subnet
SUBNET_PUBLIC_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC_CIDR \
  --availability-zone $SUBNET_PUBLIC_AZ \
    --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PUBLIC_ID' CREATED in '$SUBNET_PUBLIC_AZ'" \
  "Availability Zone."

# Add Name tag to Public Subnet
aws ec2 create-tags \
  --resources $SUBNET_PUBLIC_ID \
  --tags "Key=Name,Value=$SUBNET_PUBLIC_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PUBLIC_ID' NAMED as" \
  "'$SUBNET_PUBLIC_NAME'."

# Create Private Subnet
echo "Creating Private Subnet..."
SUBNET_PRIVATE_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE_CIDR \
  --availability-zone $SUBNET_PRIVATE_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PRIVATE_ID' CREATED in '$SUBNET_PRIVATE_AZ'" \
  "Availability Zone."

# Add Name tag to Private Subnet
aws ec2 create-tags \
  --resources $SUBNET_PRIVATE_ID \
  --tags "Key=Name,Value=$SUBNET_PRIVATE_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PRIVATE_ID' NAMED as '$SUBNET_PRIVATE_NAME'."

# Create Internet gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
  --output text \
  --region $AWS_REGION)
echo "  Internet Gateway ID '$IGW_ID' CREATED."

# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."

# Create Route Table
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.{RouteTableId:RouteTableId}' \
  --output text \
  --region $AWS_REGION)
echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED."

# Create route to Internet Gateway
OUTPUT=$(aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $AWS_REGION)
echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
  "Route Table ID '$ROUTE_TABLE_ID'."

# Associate Public Subnet with Route Table
OUTPUT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PUBLIC_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Public Subnet ID '$SUBNET_PUBLIC_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."
 

# creating security group
secgroupid=$(aws ec2 create-security-group \
--group-name "MySecurityGroup" \
--description "My security group" \
--vpc-id $VPC_ID \
--output text)

##creating security group
aws ec2 create-tags \
  --resources $secgroupid \
  --tags "Key=Name,Value=$SEC_NAME" \
  --region $AWS_REGION
echo "  SEC ID '$secgroupid' NAMED as '$SEC_NAME'."

# inbound rules
aws ec2 authorize-security-group-ingress \
    --group-id  $secgroupid \
    --protocol "tcp" \
    --port 22 \
    --cidr "0.0.0.0/0"
    echo "port 22 to security group "

 # inbound rules
aws ec2 authorize-security-group-ingress \
    --group-id  $secgroupid \
    --protocol "tcp" \
    --port 80 \
    --cidr "0.0.0.0/0"
    echo "port 22 to security group " 


    # inbound rules
     aws ec2 authorize-security-group-ingress \
    --group-id  $secgroupid \
    --protocol "tcp" \
    --port 443 \
    --cidr "0.0.0.0/0"
    echo "port 22 to security group "  


    #creating instance
    EC2_ID=$(aws ec2 run-instances \
  --image-id $IMAGE_ID \
  --count 1 \
  --security-group-ids $secgroupid \
  --subnet-id $SUBNET_PUBLIC_ID \
  --instance-type $TYPE \
  --key-name $KEY_NAME \
  --associate-public-ip-address \
  --query 'Instances[0].{InstanceId:InstanceId}')
  echo "  EC2 ID '$EC2_ID' CREATED in '$AWS_REGION' region."

# Add Name tag to EC2
aws ec2 create-tags \
  --resources $EC2_ID \
  --tags "Key=Name,Value=$INSTANCE_NAME" \
  --region $AWS_REGION
echo "  EC2 ID '$EC2_ID' NAMED as '$INSTANCE_NAME'."










