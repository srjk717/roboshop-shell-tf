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

VALIDATE $? "Installing nodeJS Repos"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing nodeJS"

useradd roboshop &>>$LOGFILE

VALIDATE $? "Adding Roboshop user"

mkdir /app &>>$LOGFILE

VALIDATE $? "Moving to App Directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE

VALIDATE $? "Downloading roboshop artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving To App Directory"

unzip /tmp/cart.zip &>>$LOGFILE

VALIDATE $? "Unzipping Cart Service"

npm install &>>$LOGFILE

VALIDATE $? "Installing NPM"

cp /home/centos/roboshop-Shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE

VALIDATE $? "Copying cart.service to /etc folder"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Deamon Reload"

systemctl enable cart &>>$LOGFILE

VALIDATE $? "Enabling cart.service"

systemctl start cart &>>$LOGFILE

VALIDATE $? "Starting cart.service" 
