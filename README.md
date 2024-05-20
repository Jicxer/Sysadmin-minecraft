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
