dnf install nginx -y
systemctl enable nginx
systemctl start nginx
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip

cp confid/roboshop.conf /etc/nginx/default.d/roboshop.conf
systemctl restart nginx
