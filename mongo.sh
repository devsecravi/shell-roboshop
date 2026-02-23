#!/bin/bash

USERID=$(id -u)
FILE_FOLDER="/var/log/shell-script"
FILE_LOG="$FILE_FOLDER/$0.sh"
MONGO="mongo.repo"

if [ $USERID -nq 0 ]; then
    echo "Package Installation with Super Root User $USERID"
    exit 1
fi

validate(){

     if [ $1 -nq 0 ]; then 
        echo "$2...FAILURE"
    else
        echo "$2....SUCCESS"
    fi
}
cp  mongo.repo /etc/yum.repos.d/mongo.repo | tee -a $FILE_LOG
validate $? "copying.."


