#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$FILE_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo "$R Package Installation with Super Root User $N  $USERID"
    exit 1
fi
mkdir -p $LOG_FOLDER
validate(){

     if [ $1 -ne 0 ]; then 
        echo "$2...$R FAILURE $N" | tee -a $LOG_FILE
    else
        echo "$2....$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

cp  mongo.repo /etc/yum.repos.d/mongo.repo | tee -a $LOG_FILE
validate $? "copying.."

dnf install mongodb-org -y &>>$LOG_FILE
validate $? "Installing Package.." | tee -a $LOG_FILE

systemctl enable mongod &>>$LOG_FILE
validate $? "Enable Package.." | tee -a $LOG_FILE
systemctl start mongod  &>>$LOG_FILE
validate $? "Start Package.." | tee -a $LOG_FILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Editing Package.." | tee -a $LOG_FILE

systemctl restart mongod
validate $? "Restarted Package.." | tee -a $LOG_FILE



