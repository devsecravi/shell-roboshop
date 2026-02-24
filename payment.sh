USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL=mysql.dsecops88.online
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

dnf install python3 gcc python3-devel -y    &>>$LOG_FILE
validate $? "installed python"

id $SCRIPT_DIR/roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "Creating system user"
else
         validate $? "Roboshop user already exist ...$Y SKIPPING $N"
fi

mkdir /app   &>>$LOG_FILE
validate $? "installed python" 

curl  -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip   &>>$LOG_FILE
validate $? "downloded  python.zip to temp folder"

cd /app 
validate $? "moved to change director to app" &>>$LOG_FILE

unzip /tmp/payment.zip  &>>$LOG_FILE
validate $? "unzipped payment"

pip3 install -r requirements.txt   &>>$LOG_FILE
validate $? "installed python dependies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service   &>>$LOG_FILE
validate $? "moved  payment.service to etc"

systemctl daemon-reload    &>>$LOG_FILE
validate $? "reloaded system"

systemctl enable payment   &>>$LOG_FILE
validate $? "enabled payment"

systemctl start payment  &>>$LOG_FILE
validate $? "started  payment"