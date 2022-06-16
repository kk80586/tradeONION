#!/bin/bash


chmod +x tradeONION.sh
chmod +x tradeONION.desktop
echo
echo
echo "First we will setup the KEY/SECRET pair for each exchange you wish to use."
echo "nano will be used as the editor. If for some reason you do not have nano,"
echo "you can edit manually or change editor name below before running script."
echo "If you are not going to use a specific exchange, you can just exit the editor. "
echo "TradeOgre uses only one file, the others use two. 1 for the KEY and the 2nd for SECRET."
echo "IMPORTANT: Pasted KEY and/or SECRET must be on the first line of the file."
echo "IMPORTANT: When pasting, do not add a space or hit enter, just save and exit the editor."
read -p "Press Enter to continue..." x
editor=nano

echo
echo
echo "If you do not have StakeCube API KEY/SECRET please go to https://stakecube.net/app/profile/api-keys to create them."
echo "You will need to be logged in and be sure to allow the permissions you want."
echo "Be sure you have you StakeCube API KEY/SECRET pair available. Paste the KEY into scks.txt and SECRET into scks2.txt ."
read -p "Press Enter to continue..." x
#   https://stakecube.net/app/profile/api-keys

$editor scks.txt
$editor scks2.txt

echo
echo
echo "Example of TradeOgre KEY:SECRET file -->  a1c554db73:b32da8b992 (note the colon between the two values)"
echo "If you do not have TradeOgre API KEY/SECRET please go to https://tradeogre.com/account/settings to create them."
echo "You will need to be logged in and be sure to allow the permissions you want."
echo "Be sure you have you TradeOgre API KEY/SECRET pair available. Paste the KEY:SECRET into shellogreks.txt ."
read -p "Press Enter to continue..." x 
# https://tradeogre.com/account/settings

$editor shellogreks.txt

echo
echo
echo "If you do not have SouthXchange API KEY/SECRET please go to https://main.southxchange.com/Account/Manage to create them."
echo "You will need to be logged in and be sure to allow the permissions you want."
echo "Be sure you have you SouthXchange API KEY/SECRET pair available. Paste the KEY into sxcks.txt and SECRET into sxcks2.txt ."
read -p "Press Enter to continue..." x
# https://main.southxchange.com/Account/Manage

$editor sxcks.txt
$editor sxcks2.txt
echo
echo 
echo "Would you like a launcher placed on your Desktop? (This should work on Debian based systems. Otherwise you may need to create launcher manually)."
echo "You may need to add the icon image manually."

   while true; do
     echo -e '\E[31;40m'"\033[1m"
   read -p "Would you like to continue?" yn
    case $yn in
        [Yy]* ) cp tradeONION.desktop ~/Desktop/; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
