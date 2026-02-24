#/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
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

cp mongo.sh /etc/yum.repos.d/mongo.repo 
validate $? "Copyied From Source to ETC" | tee -a $LOG_FILE

dnf install mongodb-org -y &>>$LOG_FILE
validate $? "Insatlling mongodb" | tee -a $LOG_FILE

systemctl enable mongod &>>$LOG_FILE
validate $? "Enabled mongodb" | tee -a $LOG_FILE

systemctl start mongod &>>$LOG_FILE
validate $? "Started mongodb" | tee -a $LOG_FILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Allowing remote connections" | tee -a $LOG_FILE

systemctl restart mongod 
validate $? "Restarted MongoDB" | tee -a $LOG_FILE

