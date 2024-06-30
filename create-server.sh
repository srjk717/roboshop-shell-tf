#!/bin/bash

NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-0f3c7d07486cad139
SECURITY_GROUP_ID=sg-0612ba1e6231c0958
DOMAIN_NAME=rahuldevops.online
Hosted_ZONE_ID=Z1037679PWH8BTMNZ3SR

#IF MY SQL OR MONGODB INSTANCE_TYPE SHOULD BE T3.MICRO FOR ALL OTHERS IT IS T2.MICRO

for i in $@
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

    aws route53 change-resource-record-sets --hosted-zone-id $Hosted_ZONE_ID --change-batch '
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
# check route 53 record already exists, if exists, update route53 record