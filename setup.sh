#!/bin/bash

# Get the directory where the script is located
script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Step 1: Install docker
echo "Step 1: Installing Docker"
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Step 2: Login to Docker
echo "Step 2: Logging into Docker"
sudo docker login

# # Step 3: Run Docker
echo "Step 3: Running Docker Compose"
sudo docker-compose up -d

# # Step 4: Logout from Docker
echo "Step 4: Logging out from Docker"
sudo docker logout

# Step 5: Create systemd service
echo "Step 5: Creating systemd service"
sudo bash -c 'cat <<EOF > /etc/systemd/system/auctopus_docker.service
[Unit]
Description=Auctopus Docker Container
After=network.target

[Service]
User=root
Group=root
WorkingDirectory='"$script_directory"'
ExecStart=/usr/local/bin/docker-compose -f '"$script_directory/docker-compose.yml"' up -d
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable auctopus_docker.service
sudo systemctl start auctopus_docker.service
sudo systemctl status auctopus_docker.service
