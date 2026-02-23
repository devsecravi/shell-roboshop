#!/bin/bash

USERID=$(id -u)
FILE_FOLDER="/var/log/shell-roboshop"
FILE_LOG="$FILE_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo "Package Installation with Super Root User $USERID"
    exit 1
fi

validate(){

     if [ $1 -ne 0 ]; then 
        echo "$2...FAILURE"
    else
        echo "$2....SUCCESS"
    fi
}

cp  mongo.repo /etc/yum.repos.d/mongo.repo | tee -a $FILE_LOG
validate $? "copying.."


