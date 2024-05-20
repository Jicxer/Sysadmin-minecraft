# Minecraft Server
Final documentation for System Administration (CS312) final project at Oregon State University.

For our project, we were asked to deploy a Minecraft server on AWS as system admins for a fictional company. This would also require writing a tutorial in Markdown.
We are given broad guidelines:
- Setup an AWS EC2 instance
- Setup the right security group rules
- Install dependencies on the EC2 instance and download/setup the latest Minecraft server version
- Start the server
- Setup auto-start for the Minecraft service when the instance starts (hint: systemctl or similar)
- Connect to your instance's public IP address (i.e., your Minecraft server address) with the Minecraft client to see if it works

## Tutorial
1. From your AWS 'Console Home,' use the search bar to navigate to EC2.
The dashboard will look like this:
![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/e036ad1b-321b-4128-8244-c725dbddb0b7)

2. From the EC2 dashboard, navigate to "instances" and launch a new instance
Name this instance "Minecraft Server"
3. In the Application and OS Images section, pick the **Debian** machine image with **64-bit (Arm)** architecture
4. Select **t4g.small** for Instance Type
![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/254a94fc-95e1-4455-8526-1c5b3c2064e5)
6. In Network settings, change the vpc to default
7. click the edit button and change the security group name to **Minecraft Security Group**
8. 

Things I didn't know:
1. Installing JDK Java on EC2 Instance:
2. 
Solution: https://stackoverflow.com/questions/59430965/aws-how-to-install-java11-on-an-ec2-linux-machine
https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/generic-linux-install.html

```#!/bin/bash

# Log output for debugging
exec > /var/log/user-data.log 2>&1

# Update the system
apt-get update

# Install gnome-terminal if not installed
if ! dpkg -l | grep -q gnome-terminal; then
  apt-get install -y gnome-terminal
else
  echo "gnome-terminal is already installed."
fi

# Check and install Docker if not installed
if ! dpkg -l | grep -q docker-ce; then
  # Setting up Docker's apt repository
  apt-get install -y ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update

  # Install Docker packages
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  echo "Docker installation completed"
else
  echo "Docker is already installed."
fi
sudo systemctl enable docker

# Create the minecraft-server folder and create a yaml file called docker-compose.yml
if [ ! -d "/minecraft-server" ]; then
  mkdir /minecraft-server
  echo "Created directory /minecraft-server"
else
  echo "Directory /minecraft-server already exists."
fi

cd /minecraft-server

# Check if the docker-compose.yml file exists
filename="docker-compose.yml"
if [ ! -f "$filename" ]; then
  # Create the docker-compose.yml file with the specified content
  cat <<EOL > $filename
version: '3'
services:
  mc:
    image: itzg/minecraft-server
    restart: always
    tty: true
    stdin_open: true
    ports:
      - "25565:25565"
    environment:
      EULA: "TRUE"
    volumes:
      - ./data:/data
EOL
  echo "docker-compose.yml has been created."
else
  echo "docker-compose.yml already exists."
fi

# Start Minecraft server with docker compose and attach container to terminal
echo 'Starting Minecraft server!'

docker compose up -d
```
