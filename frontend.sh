#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please try to run script with super root user"
    exit 1
fi

mkdir -p $LOG_FOLDER

validate(){

      if [ $1 -ne 0 ]; then
        
         echo -e "$2......$R FAILURE $N" | tee -a $LOG_FILE
      else
         echo -e "$2......$G SUCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nginx -y  &>>$LOG_FILE
validate $? "disable nginx"

dnf module enable nginx:1.24 -y  &>>$LOG_FILE
validate $? "enable nginx"

dnf install nginx -y &>>$LOG_FILE
validate $? "installing nginx"

systemctl enable nginx  &>>$LOG_FILE
validate $? "enable  system"

systemctl start nginx &>>$LOG_FILE
validate $? "start  system"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
validate $? "removed temp file in nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
validate $? "copied from frontend.zp to local"

cd /usr/share/nginx/html  &>>$LOG_FILE
validate $? "change directory to user/share/nginx"

unzip /tmp/frontend.zip &>>$LOG_FILE
validate $? "unzipped fronted.zip file"

cp  $SCRIPT_DIR/nginx.conf   /etc/nginx/nginx.conf &>>$LOG_FILE
validate $? "copied file from present work directory to etc"

systemctl restart nginx &>>$LOG_FILE
validate $? "restart system"