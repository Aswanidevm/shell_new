source common.sh

roboshop_app_password=$1
if [ -z "${roboshop_app_password}" ]; then
  echo " Missing RabbitMQ App User Password argument "
  exit 1
fi
component=dispatch
golang