dirct=$(pwd)
sudo dnf install nginx -y

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
cd /usr/share/nginx/html
sudo rm -rf *
yum install unzip -y
sudo unzip /tmp/frontend.zip
systemctl enable nginx
systemctl start nginx
cp dirct/config/roboshop.conf /etc/nginx/default.d/roboshop.conf
systemctl restart nginx
