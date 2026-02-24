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


dnf install maven -y &>>$LOG_FILE
validate $? "installed maven"

id $SCRIPT_DIR/roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "Creating system user"
else
         validate $? "Roboshop user already exist ...$Y SKIPPING $N"
fi


mkdir /app  &>>$LOG_FILE
validate $? "Created App Directory"

curl  -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
validate $? "downloading zip"

cd /app 
validate $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
validate $? "Removing existing code"

unzip /tmp/shipping.zip
validate $? "Uzipped catalogue code"

mvn clean package &>>$LOG_FILE
validate $? "cleane and packaged"

mv target/shipping-1.0.jar shipping.jar 
validate $? "Moving target to app directory"

