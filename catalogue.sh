#!/usr/bin/env bash

DATE=$(date +%F)
SCRIPT_NAME="$0"
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
W="\033[0m"

if [[ $(id -u) -ne 0 ]]
then
        echo -e "$R ERROR : Please run this sctipt with root user, swich to root and try $W"
        exit 1
fi

VALIDATE()
{
    if [[ $? -ne 0 ]]
        then
                echo -e "$1 $R ..... Failure $W"
                exit 2
        else
                echo -e "$1 $G ..... Success $W"
        fi
}

# Setup NodeJS repos

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE "Setting up nodejs repo"

# Install NodeJS

yum install nodejs -y &>> $LOGFILE

VALIDATE "Installing nodejs"

# Add application User if not exist

id roboshop &>> /dev/null
if [[ $? -ne 0 ]]
then
    useradd roboshop
    VALIDATE "User roboshop created"
fi

# This is a usual practice that runs in the organization. Lets setup an app directory if not exist

DIR="/app"
if [[ ! -d "$DIR" ]] 
then
    mkdir "$DIR"
    VALIDATE "$DIR Creation"
fi

# Download the application code to created app directory

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

VALIDATE "Code downloading"

cd /app

unzip -o /tmp/catalogue.Zip &>> $LOGFILE

VALIDATE "Unzipping code"

# Install npm dependencies

npm install &>> $LOGFILE

VALIDATE "NPM dependencies installing"

# Setup SystemD Catalogue Service

cp -v /home/centos/Roboshop-shell-modified/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE "Creating catalogue service"

# Load the service

systemctl daemon-reload

# Start and Enable the service

systemctl enable catalogue &>> $LOGFILE

VALIDATE "Enabling catalogue service"

systemctl start catalogue &>> $LOGFILE

VALIDATE "Starting catalogue service"

# Creating mongo repo for client installation

cp -v /home/centos/Roboshop-shell-modified/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE "Repo creation"

# Installing mongodb-client

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE "Installing mongodb-shell"

# Load Schema

mongo --host mongodb.robomart.cloud < /app/schema/catalogue.js &>> $LOGFILE

VALIDATE "Schema loading"