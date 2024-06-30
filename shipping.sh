#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install maven -y &>>$LOGFILE

VALIDATE $? "Installing Maven"

useradd roboshop &>>$LOGFILE

VALIDATE $? "Adding user roboshop"

mkdir /app &>>$LOGFILE

VALIDATE $? "Creating a Directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE

VALIDATE $? "Downloading Shipping artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to App Directory"

unzip /tmp/shipping.zip &>>$LOGFILE

VALIDATE $? "Unzipping shipping"

mvn clean package &>>$LOGFILE

VALIDATE $? "Packaging Shipping App"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE

VALIDATE $? "renaming shipping jar"

cp /home/centos/roboshop-Shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Deamon Reload"

systemctl enable shipping &>>$LOGFILE

VALIDATE $? "Enabling Shipping"

systemctl start shipping &>>$LOGFILE

VALIDATE $? "Starting Shipping.service"

yum install mysql -y  &>>$LOGFILE

VALIDATE $? "Installing mysql"

mysql -h mysql.rahuldevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE

VALIDATE $? "Loaded countries and cities info"

systemctl restart shipping &>>$LOGFILE

VALIDATE $? "Restarting shipping"