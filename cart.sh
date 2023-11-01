dirct=$(pwd)
sudo yum install https://rpm.nodesource.com/pub_21.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
sudo useradd roboshop
mkdir /app
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip
cd /app
unzip /tmp/cart.zip
npm install
cp dirct/config/cart.service  /etc/systemd/system/cart.service
systemctl daemon-reload
systemctl enable cart
systemctl start cart