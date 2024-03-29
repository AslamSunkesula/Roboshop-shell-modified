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

# Setup NodeJS repos. Vendor is providing a script to setup the repos

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

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE "Code downloading"

cd /app

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE "Unzipping code"

# Install npm dependencies

npm install &>> $LOGFILE

VALIDATE "NPM dependencies installing"

# Setup SystemD cart Service

cp -v /home/centos/roboshope-services-scripts/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE "Creating cart service"

# Load, Enable and Start service

systemctl daemon-reload

systemctl enable cart &>> $LOGFILE

VALIDATE "Enabling cart service"

systemctl start cart &>> $LOGFILE

VALIDATE "Starting cart service"