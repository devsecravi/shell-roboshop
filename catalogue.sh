#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
MONGODB_HOST=mongodb.dsecops88.online
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

dnf module disable nodejs -y  &>>$LOG_FILE
validate $? "disable nodejs" 

dnf module enable nodejs:20  -y &>>$LOG_FILE
validate $? "enable nodejs" 

dnf install nodejs -y &>>$LOG_FILE
validate $? "Installing Nodejs"

id $SCRIPT_DIR/roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "Creating system user"
else
         validate $? "Roboshop user already exist ...$Y SKIPPING $N"
fi

mkdir /app &>>$LOG_FILE
validate $? "App  Directory Created"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? "downloading zip"

cd /app 
validate $? "Moving to app directory"

rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/catalogue.zip
validate $? "Uzip catalogue code"

npm install &>>$LOG_FILE
validate $? "Installed The NodeJs Dependancy"

cp catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
validate $? "Created systemctl service"

systemctl daemon-reload &>>$LOG_FILE
validate $? "reloaded system"

systemctl enable catalogue &>>$LOG_FILE
validate $? "enable system"

systemctl start catalogue &>>$LOG_FILE
validate $? "start system"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
validate $? "Copyied From Source to ETC" 

dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? "installing mongodb" 

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
validate $? "Restarting catalogue"



