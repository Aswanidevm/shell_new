dirct=$(pwd)
cp $dirct/config/mongo.repo  /etc/yum.repos.d/mongo.repo
sudo dnf install mongodb-org -y
sudo systemctl start mongod
sudo systemctl ebable mongod
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
sudo systemctl restart mongod