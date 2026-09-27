#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


if [ $USERID -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIADATE() {

      if [ $1 -ne 0 ]; then
        echo -e "$2... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
      else
        echo -e "$2... $G SUCCESS $N" | tee -a $LOG_FILE
    fi

}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIADATE $? "COPYING MONGODB REPO"

sudo dnf install mongodb-org -y &>>$LOGS_FILE
VALIADATE $? "INSTALLING MONGODB SERVER"

systemctl enable mongod &>>$LOGS_FILE
VALIADATE $? "ENABLING MONGODB"

systemctl start mongod
VALIADATE $? "Start MOngodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIADATE $? "Allowing remote connections"

systemctl restart mongod
VALIADATE $? "Restarted MongoDB"


