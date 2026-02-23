USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$FILE_FOLDER/$0.log"
SCRIPT_DIR=$PWD
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
        echo "$2  $R ...FAILURE $N " | tee -a $LOG_FILE
    else
        echo "$2  $G ....SUCCESS $N " | tee -a $LOG_FILE
    fi
}

dnf  module disable nodejs -y &>>$LOG_FILE
validate $? "disabled" 

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enable.." 
dnf install nodejs -y &>>$LOG_FILE
validate $? "Installing" 

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    validate $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? "Downloaded" 
cd /app
validate $? "Moving to app directory"
rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/catalogue.zip 
validate $? "Uzip catalogue code"

npm install &>>$LOG_FILE
validate $? "Installing dependencies" 

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
validate $? "copying"

systemctl daemon-reload
validate $? "reloading"

systemctl enable catalogue 
validate $? "enable"
systemctl start catalogue
validate $? "started"

cp  $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo | tee -a $LOG_FILE

dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? "installing"

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -ne 0 ]; then
   mongosh --host $MONGODB_HOST /app/db/master-data.js
    VALIDATE $? "Loading products"
 else
     echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
validate $? "Restarting catalogue"
