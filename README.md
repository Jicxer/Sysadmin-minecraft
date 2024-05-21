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

### Requirements:
- AWS Account
- Minecraft Account (Java Edition)

## Tutorial
1. From your AWS 'Console Home,' use the search bar to navigate to EC2.
The dashboard will look like this:
![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/e036ad1b-321b-4128-8244-c725dbddb0b7)

2. From the EC2 dashboard, navigate to "instances" and launch a new instance
Name this instance "Minecraft Server"
3. In the Application and OS Images section, pick tis set up machine image with **64-bit (Arm)** architecture
4. Select **t4g.small** for Instance Type

Note: Choose the storage size according to how many players you intend to house on your server.
![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/254a94fc-95e1-4455-8526-1c5b3c2064e5)
5. Generate a new key pair by clicking on the **Create new key pair**

Name the key-name to something such as "minecraft-key" and click **Create key pair**

![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/1e788000-9946-4c86-a6f9-a9a1d355d3a7)

Generating a new key will download the private key onto your local machine. **(DO NOT SHARE THIS)**

This key will access this EC2 instance, such as SSH.

6. Click the **Edit** button in Network settings at the top right corner and change the vpc setting to **default**.

Leave the subnet setting as is and have the Auto-assign public IP to **Enable**.

Create a new security group called **Minecraft Security Group** and create a fitting description.

Edit the _Inbound Security Group Rules_:

  **Type**: Custom TCP
  
  **Port Range**: 25565
  
  **Source Type**: Anywhere

![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/14af6f82-f02c-4464-bb9a-dc308cd5bb64)

7. The Configure Storage section in EC2 setup is set to a default size of 8GB for roto volume EBS. This would be the amount of storage instance has, but feel free to
add more storage as necessary.
8. Launch the instance
9. From the EC2 dashboard, select the previously created instance and connect to the instance using SSH client.
   
![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/eba40776-f7f8-417e-acfb-1010e27fb1e4)

Connecting to the instance using the SSH client makes use of the previously generated key pair at **step 5**.
Using a platform such as Powershell, SSH into the instance by following the instructions.
An example input would be:
```
ssh -i "{generated key-pair}" admin@{EC2 Instance Public DNS}
```

10. Once you've connected to the instance, enter these commands:

```
sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/Jicxer/Sysadmin-minecraft.git
cd Sysadmin-minecraft
sudo chmod +x setup.sh
sudo ./setup.sh
```

The setup script will take care of the installation of:
- Gnome terminal
- Docker & docker packages
- Minecraft server docker image

The script is provided below:

```
#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Use sudo to run it."
  exit 1
fi

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

```

## Elastic IP
The Minecraft server needs a dedicated public IP for users to connect to and associate the EC2 instance.
1. Using the search bar or under the Network & Security section on the left-hand side of EC2 Dashboard, navigate to the "Elastic IPs" section.
![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/396d276d-6987-4b95-aed1-ff4158dc6f4c)
2. Click **Allocate Elastic IP addresses**
Select your corresponding AWS region under **Network border group** and select "Amazon's pool of IPv4 Addresses," and go ahead and allocate the IP address.
3. Select the newly created Public IP address and navigate to the actions bar and select **Associate Elastic IP addresses**
4. Leave the resource type section as is and under the **Instance** section, select the previously created Minecraft-server EC2 instance.
5. Click **Associate**

Your EC2 Instance now has a dedicated IP address! You and other players can use this public IP to connect to your Minecraft Server.
Let's test this out using Minecraft Java Edition
![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/9951df5a-bd83-4627-a70d-451b182e8d62)

Use Direct Connect to input the generated IP address within the Multiplayer tab. In this instance, my Public IPv4 elastic IP address is _54.184.105.214_

![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/97ee43fe-4ba4-464b-9cfa-09bd0ea383d3)

**Congratulations!** You have now created your own dedicated Minecraft server using AWS!
Be sure to tell your friends!
**![image](https://github.com/Jicxer/Sysadmin-minecraft/assets/79224427/e3f32a15-8a02-426d-ad6f-4b2cbe30cab1)

## Conclusion
This tutorial covers how to set up a dedicated Java Minecraft server using AWS. This server deployment only contains the vanilla edition; I will cover how to install a modded server in a later tutorial.
That being said, there were a few instances where I was lost and decided to use my resources to find the answers.
A few of the things I was unsure of and decided to look up were:

1. **Installing Docker Engine on Debian**

   Installing docker would be essential as this tutorial uses a docker Minecraft image to run the server. The EC2 instance that was created has a Debian OS image with an arm architecture.
   The answer to installing the docker engine for Debian lies in the [documentation](https://docs.docker.com/engine/install/debian/#install-using-the-repository).
   The gnome-terminal was also needed to install [Docker Desktop](https://docs.docker.com/desktop/install/debian/) on Debian.
2. **Running Docker Compose at system start-up**

  Running Docker Compose at system start-up is important to have the Minecraft Server to start each time we start the AWS EC2 instance. The answer was to enable docker.service on system start-up using the command
  ```sudo systemctl enable docker```
  Additionally, when creating the initial docker-compose.yml file, the field "restart" should have the value "always" to ensure that the services always start on system start up.
  The reference to this answer is from [StackOverflow](https://stackoverflow.com/questions/43671482/how-to-run-docker-compose-up-d-at-system-start-up)

3. **Difference between Minecraft Bedrock Edition and Java Edition**

  It is important to distinguish between Bedrock and Java. The most notable difference is the ability to cross-play. Java edition is available on platforms such as Windows, Mac, and Linux, while Bedrock is available on devices such as consoles and mobile devices. Hosting a Java edition server means that only PC users can connect to the world, as opposed to having a Bedrock server. The resouce I used to find this answer was in [Microsoft's official website.](https://learn.microsoft.com/en-us/minecraft/creator/documents/differencesbetweenbedrockandjava?view=minecraft-bedrock-stable)

# What's Next?
Another implementation for this tutorial is to include a modded version. We will make use of CurseForge and the same Docker minecraft image.
The bash script would offer an option between two different installation set-ups for the server: vanilla or modded.
