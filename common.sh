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

  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip


  if [! -d "/app" ]; then
   echo " Create app directory"
   mkdir /app
  fi

  rm -rf /app/*
  cd /app

  unzip /tmp/${component}.zip

}

golang()
{
dnf install golang -y
aftifacts_setup
go mod init dispatch
go get
go build
cp ${dirct}/config/${component}.service /etc/systemd/system/${component}.service
systemctl daemon-reload
systemctl enable ${component}
systemctl start ${component}
}
