dirct=$(pwd)
cd /tmp/
rm -rf *
log=/tmp/log_file.txt


aftifacts_setup()
{
  getent passwd roboshop &>> ${log}

  if [ $? -eq 0 ]; then
      echo "yes the user exists"
  else
      echo "No, the user does not exist"
      useradd roboshop
  fi

  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${log}


  if [! -d "/app" ]; then
   echo " Create app directory"
   mkdir /app
  fi

  rm -rf /app/* &>> ${log}
  cd /app

  unzip /tmp/${component}.zip &>> ${log}

}

systemd_config()
{
  cp ${dirct}/config/${component}.service /etc/systemd/system/${component}.service &>> ${log}
  systemctl daemon-reload
  systemctl enable ${component} &>> ${log}
  systemctl start ${component} &>> ${log}
}
nginx()
{
dnf install nginx -y &>> ${log}
#curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
rm -rf /usr/share/nginx/html* &>> ${log}
aftifacts_setup
cp * /usr/share/nginx/html &>> ${log}
#yum install unzip -y
#unzip /tmp/frontend.zip
systemctl enable nginx
systemctl start nginx
cp ${dirct}/config/${component}.conf /etc/nginx/default.d/${component}.conf
systemctl restart nginx
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

