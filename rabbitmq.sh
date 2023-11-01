source common.sh

roboshop_app_password=$1
if [ -z "${roboshop_app_password}" ]; then
  echo  " Missing RabbitMQ App User Password argument "
  exit 1
fi
echo " Installing erlang"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
status $?

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
status $?

echo " Installing rabbitmq"
dnf install rabbitmq-server erlang -y
status $?

echo " Enabling rabittmq server "
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
status $?

echo " Adding User Roboshop "
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
status $?