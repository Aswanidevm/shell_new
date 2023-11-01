dirct=$(pwd)
cd /tmp/
rm -rf *
log=/tmp/log_file.txt

status()
{
  if [ $1 -eq 0 ]; then
    echo " \n Sucess"
  else
    echo " \n failed with code $1 "
  fi
}
aftifacts_setup()
{
  getent passwd roboshop &>> ${log}

  if [ $? -eq 0 ]; then
      echo " \n Yes the user exists "
  else
      echo " \n No, the user does not exist adding user roboshop "
      useradd roboshop
  fi
  status $?

  echo " \n Downloading roboshop-artifacts.s3.amazonaws.com/${component}.zip"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${log}
  status $?

  if [ -d "/app" ]; then
    echo " \n Avalable app directory "
  else
   echo " \n Create app directory"
   mkdir /app
  fi
  status $?

  rm -rf /app/* &>> ${log}
  cd /app

  echo " \n Unziping  ${component} files"
  unzip /tmp/${component}.zip &>> ${log}
  status $?
}

systemd_config()
{

  echo " \n Copying ${component}.service file"
  cp ${dirct}/config/${component}.service /etc/systemd/system/${component}.service &>> ${log}
  status $?


  systemctl daemon-reload

  echo " \n Enabling ${component} service"
  systemctl start ${component} &>> ${log}
  systemctl enable ${component} &>> ${log}
  status $?

  echo " \n Restarting ${component} service"
  systemctl restart ${component} &>> ${log}
  status $?

}


nginx()
{
  echo " \n Istalling Nginx"
  dnf install nginx -y &>> ${log}
  status $?

#curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  echo " \n Removing contents from Nginx/html "
  rm -rf /usr/share/nginx/html* &>> ${log}
  status $?

  echo " \n Artifact setup "
  aftifacts_setup
  cp * /usr/share/nginx/html &>> ${log}

 #yum install unzip -y
 #unzip /tmp/frontend.zip
  echo " \n Enabling nginx "
  systemctl enable nginx
  systemctl start nginx
  status $?

  echo " \n Copying roboshop configuraton file"
  cp ${dirct}/config/roboshop.conf /etc/nginx/default.d/roboshop.conf
  systemctl restart nginx
  status $?
}


golang()
{
  echo " \n Installing golang "
  dnf install golang -y &>> ${log}
  status $?

  echo " \n Artifacts basic setup "
  aftifacts_setup
  status $?

  echo " \n Artifacts basic setup "
  go mod init dispatch &>> ${log}
  status $?

  echo " \n Artifacts basic setup "
  go get
  go build
  status $?

  echo " \n Systemd configuraton "
  systemd_config

}

