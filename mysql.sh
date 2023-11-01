source common.sh

mysql_root_password=$1
if [ -z "${mysql_root_password}" ]; then
  echo  " Missing MySQL Root Password argument "
  exit 1
fi

echo " Disabling Mysql "
dnf module disable mysql -y
status $?

echo " Copying repo file "
cp ${dirct}/config/mysql.repo /etc/yum.repos.d/mysql.repo
status $?

echo " Installing mysql "
dnf install mysql-community-server -y
status $?

echo " Enabling mysql service "
systemctl enable mysqld
systemctl start mysqld
status $?

echo show databases | mysql -uroot -p${mysql_root_password} &>>${log}
if [ $? -ne 0 ]; then
  mysql_secure_installation --set-root-pass ${mysql_root_password}  &>>${log}
fi
status $?
