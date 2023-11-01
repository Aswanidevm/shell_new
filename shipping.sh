source common.sh
component=shipping
mysql_root_password=$1

if [ -z "${mysql_root_password}" ]; then
  echo -e "\e[31mMissing MySQL Root Password argument\e[0m"
  exit 1
fi
java
schema_type="mysql"
