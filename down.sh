#!/bin/bash
if [ "$(id -u)" != "0" ] ;
  then echo -e "\e[31m Please run as root!\033[0m"
  exit 126
fi

function check_error {
  if [ $? -ne "0" ] ;
    then echo -e "\e[31m Error!\033[0m"
    exit 126
  fi
}

# Checking if ovs is installed
which ovs-vsctl > /dev/null 2>&1
if [ $? -ne "0" ] ;
    then echo -e "\e[31m OpenvSwitch not installed! Nothing to do here...\033[0m"
    exit 127
fi

NIC="eth0"
IP=$(ip addr show br-ext | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
GW=$(ip route | grep default | awk '{print $3}')
MAC=$(ifconfig br-ext | grep "HWaddr\b" | awk '{print $5}')

ifconfig $NIC down

echo -ne "Removing the OpenvSwitch bridge...\t\t\t\t\t"
ovs-vsctl del-br br-ext
check_error
echo " Done!"
echo -ne "Giving the physical interface an IP...\t\t\t\t\t"
ifconfig $NIC $IP > /dev/null 2>&1
check_error
echo " Done!"
echo -ne "Changhing the physical interface MAC adress...\t\t\t\t"
ifconfig $NIC hw ether $MAC
check_error
echo " Done!"
echo -ne "Routing traffic through the physical interface...\t\t\t"
while $(ip route del default > /dev/null 2>&1); do :; done
route add default gw $GW $NIC
check_error
echo " Done!"

ifconfig $NIC up

echo -e "\033[1mConfiguration successfully reverted\033[0m"
