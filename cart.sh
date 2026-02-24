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
dnf module enable nodejs:20 -y  &>>$LOG_FILE
validate $? "disabled nodejs" 

dnf install nodejs -y &>>$LOG_FILE
validate $? "disabled nodejs" 

id $SCRIPT_DIR/roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
   
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "system user created"
else
    validate $? "Sysrem User Already Exited"
fi

mkdir /app &>>$LOG_FILE
validate $? "Created App Directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip   &>>$LOG_FILE
validate $? "downloading zip"

cd /app 
validate $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
validate $? "Removing existing code"

unzip /tmp/cart.zip 
validate $? "Uzipped cart code"

npm install  &>>$LOG_FILE
validate $? "Installed The NodeJs Dependancy"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOG_FILE
validate $? "Moved cart.service file"

systemctl daemon-reload &>>$LOG_FILE
validate $? "reloaded cart" 

systemctl enable cart &>>$LOG_FILE
validate $? "enabled cart" 

systemctl start cart
validate $? "started cart" 
