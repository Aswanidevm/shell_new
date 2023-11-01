source common.sh

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

mysql_secure_installation --set-root-pass RoboShop@1
mysql -uroot -pRoboShop@1
status $?
