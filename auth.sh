#!/bin/bash
cd $HOME

echo 'Create/Update User'
read -p 'Username: ' username
read -sp 'Password: ' password
htpasswd -db "$HOME/.htpasswd" $username $password
clear
echo 'Success'
echo
echo 'Info: you need to restart for change to take effect'
read -n 1 -s -r -p 'Press any key to continue'
exit 0
