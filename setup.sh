#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Use sudo to run it."
  exit 1
fi

# Log output for debugging

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
    $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update

  # Install Docker packages
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  echo "Docker installation completed"
else
  echo "Docker is already installed."
fi

# Enable Docker to start on boot
systemctl enable docker

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
