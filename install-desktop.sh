#!/bin/bash

# Assign the first parameter to ACTIVEUSER
ACTIVEUSER=$1
token=$2

# Set echo on
set -x
export NEEDRESTART_MODE=a 

# Install xfce 
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4
sudo apt install xfce4-session


# Install RDP
sudo apt-get -y install xrdp
sudo systemctl enable xrdp
sudo adduser xrdp ssl-cert
echo xfce4-session >~/.xsession

sudo systemctl restart xrdp
sudo apt install firefox -y


sudo apt-get -y install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y
# sudo dpkg -i google-chrome*.deb # Might show "errors", fixed by next line
# sudo apt-get update
# sudo apt-get install -f -y
google-chrome --version # 查看版本

# curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# sudo apt install ./google-chrome-stable_current_amd64.deb
sudo apt-get -y install ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy
