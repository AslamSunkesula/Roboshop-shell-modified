#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
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


# Configure YUM Repos from the script provided by vendor

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE

VALIDATE "Configuring erlnag yum repos"

# Configure YUM Repos for RabbitMQ.

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE

VALIDATE "Configuring Rabbit MQ YUM Repos"

# Install RabbitMQ

yum install rabbitmq-server -y &>>$LOGFILE

VALIDATE "Installing rabbitmq-server"

# Enable and Start RabbitMQ Service

systemctl enable rabbitmq-server &>>$LOGFILE

VALIDATE "Enabling RabbitMQ Service"

systemctl start rabbitmq-server &>>$LOGFILE

VALIDATE "Starting RabbitMQ Service"

#RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect. Hence, we need to create one user for the application

rabbitmqctl add_user roboshop roboshop123&>>$LOGFILE

VALIDATE "Adding user roboshop"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE

VALIDATE "Setting up permissions"

# Validate RabbitMQ up and running and operational

netstat -tulpn | grep 5672 &>>$LOGFILE

VALIDATE "RabbitMQ Up and Operational"