# pingstatus
For use with a raspberry pi to verify an IP is alive and will have one GPIO go high from a successful reply or a different GPIO go high from a failed reply.

The idea for this script came about when a friend and I wanted a display that shows the status of a point to point VPN being up or down with just a simple LED readout. Green for VPN is up and Red for VPN is down. You can use it to ping anything that will reply, really. I decided to write this simple bash script. This is intended to be used with a raspberry Pi and utilizes its GPIO pins for the display of a successful or a failed reply from a ping. We intended on using Green/Red LED's but there is no reason you can't have it attach to a relay and have it do whatever you want (start up revolving lights, start up an air raid siren.. whatever you can imagine..). I have added functionality for a webserver so that you can check the status via a browser in addition to the LED's. If you leave the page up it will automatically refresh every 5 minutes.

To use it is simple. 

INSTALLATION

First you will want to install apache:

sudo apt update

sudo apt upgrade

sudo apt install apache2 -y

sudo usermod -a -G www-data pi

sudo chown -R -f www-data:www-data /var/www/html

Create a directory 'pingstatus' under /home/pi and place the script and jpg files inside. 

Move the jpg and index.html files to /var/www/html:

mv /home/pi/*.jpg /var/www/html

mv /home/pi/index.html /var/www/html

To use the script:
(Note: You may need to run this with a sudo in front for the first time)

USAGE

This script requires four parameters to function. Here is the
syntax and definition of each argument.

Syntax: ./pingstatus.sh [-h] [Target IP address] [Target name] [Success GPIO] [Fail GPIO]

  options:
  
        h                               - Print this Help.
        
        Target IP Address               - Desired valid IP to ping
        
        Target name                     - A nickname you would like to give to the Target
        
        Success GPIO                    - GPIO Pin to be used for successful reply (02-27)
        
        Fail GPIO                       - GPIO Pin to be used for failed reply (02-27)
        

  Example:

        ./pingstatus.sh 192.168.10.100 DaveVPN 17 27
       
This is intended to be run in cron, but I suggest running it a few times on the command line to ensure it's working properly. I suggest running it against a good target IP that is up first, and then running it against a bogus IP to test the fail result. You can have multiple crons, for instance:

* * * * * /home/pi/pingstatus/pingstatus.sh 192.168.10.100 DaveVPN 17 27
* * * * * /home/pi/pingstatus/pingstatus.sh 192.168.20.150 RobVPN 23 34
* * * * * /home/pi/pingstatus/pingstatus.sh 192.168.1.25 JamesNAS 04 05

Note! Ensure you do not use the same GPIO port twice anywhere! 

What is happening when you run the script? 

It will first verify your arguments are correctly entered (valid IP, valid GPIO ports, same GPIO ports not chosen)
It will first create a subdirectory if it doesn't already exist under the pingstatus directory with your chosen nickname, such as /home/pi/pingstatus/DaveVPN.
If this is not the first time running the ping status it will clean out any prior results files in the nickname subdirectory.
It will then ping the IP that you chose and will place the results of the ping into a text file in the nickname subdirectory.
It will then analyze that text file whether there was a successful or failed reply from the desired ip address and will create a file based if the ip is up or down.
It will then prepare the GPIO ports
It will then look at whether there is an up or down ping result file in the nickname subdirectory and will set the successful or failed designated gpio value to 1.






