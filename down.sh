#!/bin/bash
if [ "$(id -u)" != "0" ] ;
  then echo -e "\e[31m Please run as root!\033[0m"
  exit 126
fi

function check_error {
  if [ $? -ne "0" ] ;
    then echo -e "\e[31mError!\033[0m"
    exit 126
  fi
}

function reset_ovs {
  NIC="eth0"
  IP=$(ip addr show br-ext | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
  GW=$(ip route | grep default | awk '{print $3}')
  MAC=$(ifconfig br-ext | grep "HWaddr\b" | awk '{print $5}')
  MASK=$(ip addr show br-ext | grep "inet\b" | awk '{print $2}' | cut -d/ -f2)

  echo -ne "Giving the physical interface an IP...\t\t\t\t\t"
  ifconfig $NIC $IP/$MASK > /dev/null 2>&1
  check_error
  echo "Done!"

  echo -ne "Changhing physical interface MAC adress...\t\t\t\t"
  ifconfig $NIC down
  check_error
  ifconfig $NIC hw ether $MAC
  check_error
  ifconfig $NIC up
  check_error
  echo "Done!"

  echo -ne "Removing the OpenvSwitch bridge...\t\t\t\t\t"
  ovs-vsctl del-br br-ext
  check_error
  echo "Done!"

  echo -ne "Routing traffic through the physical interface...\t\t\t"
  while $(ip route del default > /dev/null 2>&1); do :; done
  ip route add default via $GW dev $NIC
  check_error
  echo "Done!"
}

reset_ovs
