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

dnf install mysql-server -y &>>$LOG_FILE
validate $? "Insatlled Mysql"

systemctl enable mysqld &>>$LOG_FILE
validate $? "enabled  Mysql"

systemctl start mysqld  &>>$LOG_FILE
validate $? "started Mysql"

mysql_secure_installation --set-root-pass RoboShop@1  &>>$LOG_FILE
VALIDATE $? "Setup root password"


