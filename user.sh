#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting Up NPM Source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing nodeJS" 

#once the user is created, if you run this script 2nd time
# this command will defnitely fail
# IMPROVEMENT: first check the user already exist or not, if not exist then create
useradd roboshop &>>$LOGFILE

VALIDATE $? "Adding User Roboshop" 

#write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

VALIDATE $? "Creating a DIRECTORY"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? "Downlading user artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/user.zip &>>$LOGFILE

VALIDATE $? "Unzipping user"

npm install &>>$LOGFILE

VALIDATE $? "Installing NPM dependencies"

cp /home/centos/roboshop-Shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "copying user.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Deamon Reload"

systemctl enable user &>>$LOGFILE

VALIDATE $? "Enabling user.service"

systemctl start user &>>$LOGFILE

VALIDATE $? "Starting user.service"

cp /home/centos/roboshop-Shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing Mongo Client"

mongo --host mongodb.rahuldevops.online </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Loading user data into mongodb"

