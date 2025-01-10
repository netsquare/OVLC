# OVLC (Open Source Vulnerable labs collections) 

OVLC is an open-source penetration testing lab collection that automates the process of downloading and installing dockers in Ubuntu servers.

Warning
----
>  This project should involve system configuration changes and the installation of multiple utilities such as dialog, Docker, etc. Additionally, it requires downloading multiple vulnerable labs. So, installing it on your primary working machine is not a good idea. Instead, **we suggest creating a separate virtual machine based on Ubuntu LTS and installing it there.** Installing it on your working machine, such as Kali Linux, may result in system breakage and potential availability issues.</span>

Installation
----

1. Install the Ubuntu Desktop LTS version in the virtual machine.
2. Open the terminal and switch to the root user by using the "sudo su" command.
3. #git clone https://github.com/netsquare/OVLC.git
4. #bash setup.sh
5. #reboot
6. Open the terminal and switch to the root user by using the "sudo su" command. Then, execute the "ovlc" command.

Usage
----

Login to the machine and execute the command "ovlc"

![ovlc](image/ovlc.png)

Start the lab

![start](image/start.png)

