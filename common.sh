dirct=$(pwd)
cd /tmp/
rm -rf *
log=/tmp/log_file.txt

status()
{
  if [ $1 -eq 0 ]; then
    echo "   Sucess"
  else
    echo "   failed with code $1 "
  fi
}
aftifacts_setup()
{
  getent passwd roboshop &>> ${log}

  if [ $? -eq 0 ]; then
      echo "   Yes the user exists "
  else
      echo "   No, the user does not exist adding user roboshop "
      useradd roboshop
  fi
  status $?

  echo "   Downloading roboshop-artifacts.s3.amazonaws.com/${component}.zip"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${log}
  status $?

  if [ -d "/app" ]; then
    echo "   Avalable app directory "
  else
   echo "   Create app directory"
   mkdir /app
  fi
  status $?

  rm -rf /app/* &>> ${log}
  cd /app

  echo "   Unziping  ${component} files"
  unzip /tmp/${component}.zip &>> ${log}
  status $?
}

systemd_config()
{

  echo "   Copying ${component}.service file"
  cp ${dirct}/config/${component}.service /etc/systemd/system/${component}.service &>> ${log}
  status $?


  systemctl daemon-reload

  echo "   Enabling ${component} service"
  systemctl start ${component} &>> ${log}
  systemctl enable ${component} &>> ${log}
  status $?

  echo "   Restarting ${component} service"
  systemctl restart ${component} &>> ${log}
  status $?

}


nginx()
{
  echo "   Istalling Nginx"
  dnf install nginx -y &>> ${log}
  status $?

#curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  echo "   Removing contents from Nginx/html "
  rm -rf /usr/share/nginx/html* &>> ${log}
  status $?

  echo "   Artifact setup "
  aftifacts_setup
  cp * /usr/share/nginx/html &>> ${log}

 #yum install unzip -y
 #unzip /tmp/frontend.zip
  echo "   Enabling nginx "
  systemctl enable nginx
  systemctl start nginx
  status $?

  echo "    Copying roboshop configuraton file"
  cp ${dirct}/config/roboshop.conf /etc/nginx/default.d/roboshop.conf
  systemctl restart nginx
  status $?
}


golang()
{
  echo "   Installing golang "
  dnf install golang -y &>> ${log}
  status $?

  echo "   Artifacts basic setup "
  aftifacts_setup
  status $?

  echo "   Artifacts basic setup "
  go mod init dispatch &>> ${log}
  status $?

  echo "   Artifacts basic setup "
  go get
  go build
  status $?

  echo "   Systemd configuraton "
  systemd_config

}

java()
{
  echo " Installing Maven"
  dnf install maven -y
  status $?

  echo " Artifacts basic setup"
  artifacts_setup

  mvn clean package
  status $?

  echo " Renaming shipping.jar file"
  mv target/shipping-1.0.jar shipping.jar
  status $?

  systemd_config

  echo " Installing1 mysql"
  dnf install mysql -y
  status $?

  echo " importing schema"
  mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql
  status $?

  systemctl restart shipping


}

