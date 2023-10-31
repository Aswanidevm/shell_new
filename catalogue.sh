dirct=$(pwd)
sudo curl -sL https://rpm.nodesource.com/setup_lts.x | bash
sudo dnf install nodejs -y
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