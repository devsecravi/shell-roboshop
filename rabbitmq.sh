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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>>$LOG_FILE
validate $? "moved rabbitmq.repo to etc"

dnf install rabbitmq-server -y &>>$LOG_FILE
validate $? "installed rabbitmq"

systemctl enable rabbitmq-server  &>>$LOG_FILE
validate $? "enabled rabbitmq"

systemctl start rabbitmq-server  &>>$LOG_FILE
validate $? "started rabbitmq"

rabbitmqctl add_user roboshop roboshop123   &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? "created user and gien permissions"