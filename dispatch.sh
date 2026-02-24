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

dnf install golang -y &>>$LOG_FILE
validate $? "installed golang"

id $SCRIPT_DIR/roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "Creating system user"
else
         validate $? "Roboshop user already exist ...$Y SKIPPING $N"
fi

mkdir /app 
validate $? "installed golang"  &>>$LOG_FILE

curl  -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip  &>>$LOG_FILE
validate $? "downloaded dispatch.zip to temp folder"

cd /app   &>>$LOG_FILE
validate $? "moved to change director to app" 

unzip /tmp/dispatch.zip  &>>$LOG_FILE
validate $? "unzipped dispatch"

go mod init dispatch   &>>$LOG_FILE
validate $? "installed dependecy golang"

go get   &>>$LOG_FILE
validate $? "installed get golang"

go build   &>>$LOG_FILE
validate $? "builded golang"
  
cp $SCRIPT_DIR/dispatch.service /etc/systemd/system/dispatch.service  &>>$LOG_FILE
validate $? "copied dispatch.service to etc"

systemctl daemon-reload  &>>$LOG_FILE
validate $? "reloaded system"

systemctl enable dispatch   &>>$LOG_FILE
validate $? "enabled golang"

systemctl start dispatch  &>>$LOG_FILE
validate $? "started golang"