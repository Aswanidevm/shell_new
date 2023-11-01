dirct=$(pwd)
cd /tmp/
rm -rf *
log=/tmp/log.txt

status()
{
  if [ $1 -eq 0 ]; then
    echo "   Sucess"
  else
    echo "   failed with code $1 "
    exit 1
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

  sed -i -e "s/ROBOSHOP_USER_PASSWORD/${roboshop_app_password}/" /etc/systemd/system/${component}.service &>>${log}

  systemctl daemon-reload

  echo " Enabling ${component} service"
  systemctl start ${component} &>> ${log}
  systemctl enable ${component} &>> ${log}
  status $?

  echo " Restarting ${component} service"
  systemctl restart ${component} &>> ${log}
  status $?

}

schema_setup() {
  if [ "${schema_type}" == "mongo" ]; then
    echo"Copy MongoDB Repo File"
    cp ${code_dir}/config/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${log}
    status $?

    echo "Install Mongo Client"
    yum install mongodb-org-shell -y &>>${log}
    status $?

    echo "Load Schema"
    mongo --host mongodb.myprojecdevops.info </app/schema/${component}.js &>>${log}
    status $?
  elif [ "${schema_type}" == "mysql" ]; then
    echo "Install MySQL Client"
    yum install mysql -y &>>${log}
    status $?

    echo "Load Schema"
    mysql -h mysql.myprojecdevops.info -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>>${log}
    status $?
  fi
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

  schema_setup

  systemd_config

}


nodejs()
{
  echo " Installing Nodejs"
  yum install https://rpm.nodesource.com/pub_21.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
  yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
  status $?

  aftifacts_setup

  echo " Installing "
  npm install
  status $?

  schema_setup
  
  systemd_config

  
}


