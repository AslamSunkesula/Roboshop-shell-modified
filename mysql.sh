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

#Developer has chosen the database MySQL. Hence, we are trying to install it up and configure it.

#CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version.


yum module disable mysql -y &>> $LOGFILE

#Setup the MySQL5.7 repo file

VALIDATE $? "Disabling MySQL 8 Version"

cp /home/centos/Roboshop-shell-modified/mysql.repo /etc/yum.repos.d/mysql.repo  &>> $LOGFILE

#Install MySQL Server


VALIDATE $? "Creating mysql.repo"


yum install mysql-community-server -y &>> $LOGFILE

#Install MySQL Server

VALIDAT $? "Installing mysql-community-server"


systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling mysql service"


Install MySQL Server &>> $LOGFILE

#Next, We need to change the default root password in order to start using the database service. Use password RoboShop@1 or any other as per your choice.

VALIDATE $? "Starting mysql service"


mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE 

VALIDATE $? "setting up root password"