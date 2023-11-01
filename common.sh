dirct=$(pwd)
rm -rf /tmp/log_file
touch /tmp/log_file


aftifacts_setup()
{
  getent passwd roboshop &>> log_file

  if [ $? -eq 0 ]; then
      echo "yes the user exists"
  else
      echo "No, the user does not exist"
      useradd roboshop
  fi

  curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.

  mkdir /app
  rm -rf /app/*
  cd /app

  unzip /tmp/dispatch.zip

}

golang()
{
dnf install golang -y
aftifacts_setup
go mod init dispatch
go get
go build
cp $dirct/config/$component.service /etc/systemd/system/$component.service
systemctl daemon-reload
systemctl enable dispatch
systemctl start dispatch
}
