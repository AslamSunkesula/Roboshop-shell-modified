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

# CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version

yum module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling MySQL 8 Version"

# Setup the MySQL5.7 repo file

cp -v /home/centos/Roboshop-shell-modified/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE "Creating mysql.repo"

# Install MySQL Server

yum install mysql-community-server -y  &>> $LOGFILE

VALIDATE "Installing mysql-community-server"

# Start and Enable MySQL Service

systemctl enable mysqld  &>> $LOGFILE

VALIDATE "Enabling mysql service"

systemctl start mysqld  &>> $LOGFILE

VALIDATE "Starting mysql service"

# We need to change the default root password in order to start using the database service. Use password RoboShop@1 or any other as per your choice

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE "Password setup"

# Validate MySQL is Up and Operational.

netstat -tulpn | grep 3306 &>> $LOGFILE

VALIDATE "MySQL Status Validation"