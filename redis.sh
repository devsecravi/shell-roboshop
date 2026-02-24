#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then

   echo -e echo -e "$R Please try to run script with super root user"
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

dnf module disable redis -y &>>$LOG_FILE
validate $? "disabled redis" 

dnf module enable redis:7 -y &>>$LOG_FILE
validate $? "enabled  redis" 

dnf install redis -y &>>$LOG_FILE
validate $? "insatlled  redis" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf 
validate $? "Allowing remote connections" 

systemctl enable redis &>>$LOG_FILE
validate $? "enabled  redis" 

systemctl start redis &>>$LOG_FILE
validate $? "started  redis"