#!/bin/bash

        IP_Arg=$1
      NAME_Arg=$2
   SUCCESS_Arg=$3
      FAIL_Arg=$4
      GREP_Arg="bytes from $IP_Arg"

# Help display
function Help()
{
     echo "DESCRIPTION"
     echo
     echo "This script will ping an IP address and by utilizing the GPIO pins"
     echo "on a raspberry pi it will set one of two GPIO pins to hi based on"
     echo "a positive or negative reply. The GPIO pins can be then used to"
     echo "turn on/off an LED, activate a relay to set off mayhem, etc. A"
     echo "successful reply will activate one specified GPIO pin. A negative"
     echo "reply will activate an alternate specified GPIO pin."
     echo 
     echo "USAGE"
     echo
     echo "This script requires four parameters to function. Here is the"
     echo "syntax and definition of each argument."
     echo
     echo "Syntax: $0 [-h] [Target IP address] [Target name] [Success GPIO] [Fail GPIO]"
     echo "  options:"
     echo -e "\th    \t\t\t\t- Print this Help."
     echo -e "\tTarget IP Address\t\t- Desired valid IP to ping"
     echo -e "\tTarget name\t\t\t- A nickname you would like to give to the Target"
     echo -e "\tSuccess GPIO\t\t\t- GPIO Pin to be used for successful reply (02-27)"
     echo -e "\tFail GPIO\t\t\t- GPIO Pin to be used for failed reply (02-27)"
     echo
     echo "  Example:"
     echo
     echo -e "\t./pingstatus.sh 192.168.10.100 DaveVPN 17 27"
     echo
     echo
}

while getopts ":h" option; do
   case $option in
      h) # display help
         Help
         exit;;
     \?) #incorrect option
         echo "Error: Invalid option"
         Help
         exit;;
   esac
done

# Argument 1 verification
function verify_first_arg()
{

ip=${IP_Arg:-1.2.3.4}

re='^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}'
 re+='0*(1?[0-9]{1,2}|2([‌​0-4][0-9]|5[0-5]))$'

if [[ $ip =~ $re ]]; then
  echo "First argument verified"
else
  echo
  echo "***Invalid IP entered"
  echo 
  Help
  exit 1
fi

}

# Argument 3 verification
function verify_third_arg()
{

if [[ "$SUCCESS_Arg" =~ ^(02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27)$ ]]; then
    echo "Third argument verified"
else
    echo
    echo "***Invalid GPIO entered for Success GPIO"
    echo
    Help
    exit 1 
fi

}

# Argument 4 verification
function verify_fourth_arg()
{

if [[ "$FAIL_Arg" =~ ^(02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27)$ ]]; then
    echo "Fourth argument verified"
else
    echo
    echo "***Invalid GPIO entered for Fail GPIO"
    echo
    Help
    exit 1
fi

}

# Verify 3 and 4 arguments are not equal
function verify_third_fourth_args_not_equal()
{

if [ "$SUCCESS_Arg" != "$FAIL_Arg" ]; then
    echo "Using two different GPIO values verified"
else
    echo
    echo "***You cannot use the same GPIO value for both Success and Fail GPIO ports."
    echo
    Help
    exit 1
fi

}

# Prepare the working directory
function name_directory_prep()
{

     mkdir -p /home/pi/pingstatus/${NAME_Arg}
     rm   -rf /home/pi/pingstatus/${NAME_Arg}/resultname*
     sudo sed -i "/${NAME_Arg}/d" /var/www/html/index.html
     sudo sed -i "/${NAME_Arg}/d" /var/www/html/index.html

}

# Ping the Target
function ping_target()
{

     ping -c4 ${IP_Arg} > /home/pi/pingstatus/${NAME_Arg}/name${NAME_Arg}ping.txt

}

# Check the results of the ping test
function check_ping_results()
{

     grep -qi "$GREP_Arg" /home/pi/pingstatus/${NAME_Arg}/name${NAME_Arg}ping.txt ; case "$?" in "0") touch /home/pi/pingstatus/${NAME_Arg}/resultname${NAME_Arg}up.txt ;; "1") touch /home/pi/pingstatus/${NAME_Arg}/resultname${NAME_Arg}down.txt ;; *) echo "error" ;; esac

}

# LED and GPIO Section

# Utility function to export a pin if not already exported
function exportPin()
{
  if [ ! -e /sys/class/gpio/gpio${SUCCESS_Arg} ]; then echo ${SUCCESS_Arg} > /sys/class/gpio/export; fi
  if [ ! -e /sys/class/gpio/gpio${FAIL_Arg} ]; then echo ${FAIL_Arg} > /sys/class/gpio/export; fi
}

# Utility function to set a pin as an output
function setOutput()
{
  echo out > /sys/class/gpio/gpio${SUCCESS_Arg}/direction
  echo out > /sys/class/gpio/gpio${FAIL_Arg}/direction
}

# Utility function to turn on Success GPIO
function setSuccessOn()
{
  echo 1 > /sys/class/gpio/gpio${SUCCESS_Arg}/value
}

# Utility function to turn on Fail GPIO
function setFailOn()
{
  echo 1 > /sys/class/gpio/gpio${FAIL_Arg}/value
}

# Utility function to turn all GPIO off
allGPIOOff()
{
  echo 0 > /sys/class/gpio/gpio${SUCCESS_Arg}/value
  echo 0 > /sys/class/gpio/gpio${FAIL_Arg}/value
}

# Utility function to set Web status to Success
function setWebSuccess()
{
     sudo cp /var/www/html/green-light.jpg /var/www/html/${NAME_Arg}-light.jpg
     sleep $[ ( $RANDOM % 5 )  + 1 ]s
     sudo sed -i "/<!-- STATUS -->/a <img src="${NAME_Arg}-light.jpg"> "${NAME_Arg}" <br>" /var/www/html/index.html
}

# Utility function to set Web Status to Fail
function setWebFail()
{
     sudo cp /var/www/html/red-light.jpg /var/www/html/${NAME_Arg}-light.jpg
     sleep $[ ( $RANDOM % 5 )  + 1 ]s
     sudo sed -i "/<!-- STATUS -->/a <img src="${NAME_Arg}-light.jpg"> "${NAME_Arg}" <br>" /var/www/html/index.html 
}

# Main Program Execution

function execute_main_program()
{ 

# SECTION Verify Arguments

     verify_first_arg
     verify_third_arg
     verify_fourth_arg
     verify_third_fourth_args_not_equal

# SECTION Run the VPN Ping Check

     name_directory_prep
     ping_target
     check_ping_results

# SECTION Setup GPIOs

# Turn GPIO off to begin 

     allGPIOOff

# Export pins so that we can use them

     exportPin 

# Set pins as outputs

     setOutput

# SECTION Activate GPIO based on results

# Check if file exists and take action based on file found

     if [ -f "/home/pi/pingstatus/${NAME_Arg}/resultname${NAME_Arg}up.txt" ]; then
         setSuccessOn
         setWebSuccess
     fi
     if [ -f "/home/pi/pingstatus/${NAME_Arg}/resultname${NAME_Arg}down.txt" ]; then
         setFailOn
         setWebFail
     fi
}

if [ $# = 0 ] ; then echo -e "*** No arguments have been entered. Here is the help file to display usage.\n"; Help; fi
if [ $# = 1 ] ; then echo -e "*** Only one argument has been entered. Here is the help file to display usage.\n"; Help; fi
if [ $# = 2 ] ; then echo -e "*** Only two arguments have been entered. Here is the help file to display usage.\n"; Help; fi
if [ $# = 3 ] ; then echo -e "*** Only three arguments have been entered. Here is the help file to display usage.\n"; Help; fi
if [ $# = 4 ] ; then execute_main_program; fi
if [ $# -ge 5 ] ; then echo "*** Too many arguments have been entered. Here is the help file to display usage.\n"; Help; fi
