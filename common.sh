dirct=$(pwd)
cd /tmp/
rm -rf *
log=/tmp/log_file.txt

status()
{
  if [ $1 -eq 0]; then
    echo " Sucess"
  else
    echo " failed with code $1 "
  fi
}
aftifacts_setup()
{
  getent passwd roboshop &>> ${log}

  if [ $? -eq 0 ]; then
      echo "yes the user exists"
  else
      echo "No, the user does not exist"
      useradd roboshop
  fi
  status $?

  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${log}
  status $?

  if [ -d "/app" ]; then
    echo " avalable app directory"
  else
   echo " Create app directory"
   mkdir /app
  fi
  status $?
  rm -rf /app/* &>> ${log}
  cd /app
  echo " Unziping  ${component} files"
  unzip /tmp/${component}.zip &>> ${log}
  status $?
}

systemd_config()
{
  cp ${dirct}/config/${component}.service /etc/systemd/system/${component}.service &>> ${log}
  status $?
  systemctl daemon-reload
  status $?
  systemctl enable ${component} &>> ${log}
  status $?
  systemctl start ${component} &>> ${log}
  status $?
}
nginx()
{
  echo " Istalling Nginx"
  dnf install nginx -y &>> ${log}
  status $?
#curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  echo " Removing contents from Nginx/html "
  rm -rf /usr/share/nginx/html* &>> ${log}
  status $?
  echo " Artifact setup "
  aftifacts_setup
  cp * /usr/share/nginx/html &>> ${log}

#yum install unzip -y
#unzip /tmp/frontend.zip
  echo " Enabling nginx "
  systemctl enable nginx
  systemctl start nginx
  status $?
  echo "copying roboshop configuraton file"
  cp ${dirct}/config/roboshop.conf /etc/nginx/default.d/roboshop.conf
  systemctl restart nginx
  status $?
}
golang()
{
dnf install golang -y &>> ${log}
aftifacts_setup
go mod init dispatch &>> ${log}
go get
go build
systemd_config
}

