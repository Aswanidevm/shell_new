source common.sh

echo " Installing erlang"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
status $?

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
status $?

echo " Installing rabbitmq"
dnf install rabbitmq-server -y
status $?

echo " Enabling rabittmq server "
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
status $?

echo " Adding User Roboshop "
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
status $?