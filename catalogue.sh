dirct=$(pwd)
sudo yum install https://rpm.nodesource.com/pub_21.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
sudo useradd roboshop
sudo curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
sudo mkdir /app
sudo cd /app
sudo unzip /tmp/catalogue.zip
sudo npm install
sudo cp $dirct/config/catalogue.service /etc/systemd/system/catalogue.service
sudo systemctl daemon-reload
sudo systemctl enable catalogue
sudo systemctl start catalogue
sudo cp $dirct/config/mongo.repo /etc/yum.repos.d/mongo.repo
sudo dnf install mongodb-org-shell -y
mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js