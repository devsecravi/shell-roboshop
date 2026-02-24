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

dnf module disable nodejs -y &>>$LOG_FILE
validate $? "disabled nodejs" 

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enabled nodejs" 

dnf install nodejs -y &>>$LOG_FILE
validate $? "installed nodejs" 


id $SCRIPT_DIR/roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "Creating system user"
else
         validate $? "Roboshop user already exist ...$Y SKIPPING $N"
fi

mkdir /app  &>>$LOG_FILE
validate $? "Created App Directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
validate $? "downloading zip"

cd /app 
validate $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
validate $? "Removing existing code"

unzip /tmp/user.zip
validate $? "Uzipped catalogue code"

npm install &>>$LOG_FILE
validate $? "Installed The NodeJs Dependancy"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOG_FILE
validate $? "Moved User.service file"

systemctl daemon-reload &>>$LOG_FILE
validate $? "reloaded system"

systemctl enable user &>>$LOG_FILE
validate $? "enabled user"

systemctl start user  &>>$LOG_FILE
validate $? "Started User"

