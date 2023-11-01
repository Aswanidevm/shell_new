dirct=$(pwd)
dnf module disable mysql -y
cp $dirct/config/mysql.repo /etc/yum.repos.d/mysql.repo
dnf install mysql-community-server -y
systemctl enable mysqld
systemctl start mysqld
mysql_secure_installation --set-root-pass RoboShop@1
mysql -uroot -pRoboShop@1