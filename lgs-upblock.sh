#!/bin/bash

CONFIG_FILE='logiscoin.conf'
CONFIGFOLDER='/root/.logiscoin'
COIN_DAEMON='/usr/local/bin/logiscoind'
COIN_CLI='/usr/local/bin/logiscoin-cli'
COIN_REPO='https://github.com/lgsproject/LogisCoin/releases/download/v2.0.0.0/logiscoin-2.0.0-x86_64-linux-gnu.tar.gz'
COIN_NAME='LogisCoin'
COIN_PORT=48484

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function compile_node() {

  echo -e "Stop the $COIN_NAME wallet daemon"
  if (( $UBUNTU_VERSION == 16 || $UBUNTU_VERSION == 18 )); then
    systemctl stop $COIN_NAME.service
  else
    /etc/init.d/$COIN_NAME stop
  fi
  sleep 7
  
  echo -e "Remove the old blockchain files from the system"
  rm -rf $CONFIGFOLDER/blocks/ >/dev/null 2>&1
  rm -rf $CONFIGFOLDER/chainstate/ >/dev/null 2>&1
  rm $CONFIGFOLDER/mnpayments.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/fee_estimates.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/peers.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/budget.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/mncache.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/debug.log >/dev/null 2>&1
  rm $CONFIGFOLDER/db.log >/dev/null 2>&1
  sleep 5
  clear
  
  echo -e "Start the $COIN_NAME wallet daemon"
  if (( $UBUNTU_VERSION == 16 || $UBUNTU_VERSION == 18 )); then
    systemctl start $COIN_NAME.service
  else
    /etc/init.d/$COIN_NAME start
  fi
  sleep 7
  clear
}

function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

function detect_ubuntu() {
 if [[ $(lsb_release -d) == *18.04* ]]; then
   UBUNTU_VERSION=18
 elif [[ $(lsb_release -d) == *16.04* ]]; then
   UBUNTU_VERSION=16
 elif [[ $(lsb_release -d) == *14.04* ]]; then
   UBUNTU_VERSION=14
else
   echo -e "${RED}You are not running Ubuntu 14.04, 16.04 or 18.04 Installation is cancelled.${NC}"
   exit 1
fi
}

function checks() {
 detect_ubuntu 
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi
}

function prepare_system() {
echo -e "Prepare the system to update blockchain for ${GREEN}$COIN_NAME${NC} master node."
  sleep 7
}

function important_information() {
 echo
 echo -e "================================================================================"
 echo -e "$COIN_NAME Masternode wallet is update blockchain and running, listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 if (( $UBUNTU_VERSION == 16 || $UBUNTU_VERSION == 18 )); then
   echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
   echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
   echo -e "Status: ${RED}systemctl status $COIN_NAME.service${NC}"
 else
   echo -e "Start: ${RED}/etc/init.d/$COIN_NAME start${NC}"
   echo -e "Stop: ${RED}/etc/init.d/$COIN_NAME stop${NC}"
   echo -e "Status: ${RED}/etc/init.d/$COIN_NAME status${NC}"
 fi
 echo -e "Check if $COIN_NAME is running by using the following command:\n${RED}ps -ef | grep $COIN_DAEMON | grep -v grep${NC}"
 echo -e "The old blockchain is deleted, wait for synchronization with the network."
 echo -e "After the wallet is synchronized with the network, you can run Masternodes."
 echo -e "================================================================================"
}

##### Main #####
clear

checks
prepare_system
compile_node
important_information