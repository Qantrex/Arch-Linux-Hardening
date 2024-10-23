#!/bin/bash

#VAIRABLES
new_username="test"
new_password="test"
ssh_port=2222
new_root_password="your_new_password_here"
programs=("openssh", "sudo", "git", "nmap")

function security_scan {
    # Prompt for the target IP or hostname
    read -p "Enter the target IP or hostname (or type 'localhost' for local scan): " target

    # Perform the Nmap scan
    echo "Starting Nmap security scan on $target..."
    nmap -sS -sV --script vuln "$target" -oN "${target}_security_scan.txt"

    # Check the results
    if [[ $? -eq 0 ]]; then
        echo "Scan completed successfully. Results saved to ${target}_security_scan.txt."
    else
        echo "Scan failed. Please check your target and try again."
        exit 1
    fi
}

# Set new root password
echo -e "$new_root_password\n$new_root_password" | passwd root

for program in "${programs[@]}"; do
    if ! pacman -Qi "$program" > /dev/null; then
        pacman -S --noconfirm "$program"
        echo "$program has been installed."
    else
        echo "$program is already installed."
    fi
done
systemctl enable sshd
systemctl start sshd
	
# Permit SSH root login
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# Create the user
useradd -m -s /bin/bash "$new_username"

# Set the password
echo "$new_username:$new_password" | chpasswd

# Add user to sudo group
usermod -aG wheel "$new_username"

# Ensure sudo group has sudo privileges
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Allow only the new user to login via SSH
echo "AllowUsers $username" >> /etc/ssh/sshd_config

# Disable password authentication and enforce key-based login
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Change the default SSH port
sed -i "s/^#Port 22/Port $ssh_port/" /etc/ssh/sshd_config

# Restart SSH service to apply changes
systemctl restart sshd

# List all active services
systemctl --type=service --state=running

# Prompt the user for services to disable
read -p "Enter the service name you want to disable (leave empty to skip): " service_name

while [ ! -z "$service_name" ]; do
    # Disable the selected service
    systemctl disable --now "$service_name"
    echo "Disabled $service_name"

    # Prompt again for another service or finish
    read -p "Enter another service name to disable (leave empty to finish): " service_name
done

# Set proper permissions for critical directories
chmod 700 /etc
chmod 700 /usr/local/etc

# Restrict access to sensitive files
chmod 600 /etc/master.passwd
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

# Ensure ownership is correct
chown root:root /etc/master.passwd /etc/shadow /etc/gshadow /etc /usr/local/etc

# Ensure all packages are updated
pacman -Syu --noconfirm

# Create a script for daily system updates
# Arch Linux recommends against automated updates due to security concers because pacman expects user inteeraction to make important decisions so a force update without consideration is useless and creates new security concers