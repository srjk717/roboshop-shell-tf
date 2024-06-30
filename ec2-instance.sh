#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
INSTANCE_TYPE=""
IMAGE_ID=ami-0f3c7d07486cad139
SECURITY_GROUP_ID=sg-0612ba1e6231c0958
DOMAIN_NAME=rahuldevops.online

#IF MY SQL OR MONGODB INSTANCE_TYPE SHOULD BE T3.MICRO FOR ALL OTHERS IT IS T2.MICRO

for i in "${NAMES[@]}"
do 
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then 
        INSTANCE_TYPE="t3.micro"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    echo "Creating $i Instance"

    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')

    echo "Created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z1037679PWH8BTMNZ3SR --change-batch '
    {
                "Changes": [{
                "Action": "CREATE",
                            "ResourceRecordSet": {
                                        "Name": "'$i.$DOMAIN_NAME'",
                                        "Type": "A",
                                        "TTL": 1,
                                    "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                            }}]
    }
    '
done

# imporvement
# check instance is already created or not
# update route53 record