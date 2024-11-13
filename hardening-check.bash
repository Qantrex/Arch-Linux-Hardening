#!/bin/bash

# Script to validate the implementation of the original script
new_username="test"
new_password="test"
ssh_port=2222
programs=("openssh" "sudo" "git" "cronie")

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check root password change
if [ "$(sudo -n true 2>&1 | grep -c 'password')" -eq 0 ]; then
    echo -e "${GREEN}Root password is set.${NC}"
else
    echo -e "${RED}Root password is not set correctly.${NC}"
fi

# Check if required programs are installed
for program in "${programs[@]}"; do
    if pacman -Qi "$program" > /dev/null; then
        echo -e "${GREEN}$program is installed.${NC}"
    else
        echo -e "${RED}$program is NOT installed.${NC}"
    fi
done

# Check if SSH service is enabled and running
if systemctl is-enabled sshd &>/dev/null && systemctl is-active sshd &>/dev/null; then
    echo -e "${GREEN}SSH service is enabled and running.${NC}"
else
    echo -e "${RED}SSH service is NOT enabled or running.${NC}"
fi

# Check SSH configuration for root login
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    echo -e "${GREEN}Root login is correctly disabled.${NC}"
else
    echo -e "${RED}Root login is NOT correctly disabled.${NC}"
fi

# Check if the user exists
if id "$new_username" &>/dev/null; then
    echo -e "${GREEN}User $new_username exists.${NC}"
else
    echo -e "${RED}User $new_username does NOT exist.${NC}"
fi

# Check if the user is in the wheel group
if groups "$new_username" | grep -q "\bwheel\b"; then
    echo -e "${GREEN}$new_username is in the wheel group.${NC}"
else
    echo -e "${RED}$new_username is NOT in the wheel group.${NC}"
fi

# Check SSH user restriction
if grep -q "^AllowUsers $new_username" /etc/ssh/sshd_config; then
    echo -e "${GREEN}SSH access is restricted to $new_username.${NC}"
else
    echo -e "${RED}SSH access is NOT restricted to $new_username.${NC}"
fi

# Check password authentication settings
if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
    echo -e "${GREEN}Password authentication is disabled.${NC}"
else
    echo -e "${RED}Password authentication is NOT disabled.${NC}"
fi

# Check if SSH port is correctly set
if grep -q "^Port $ssh_port" /etc/ssh/sshd_config; then
    echo -e "${GREEN}SSH port is set to $ssh_port.${NC}"
else
    echo -e "${RED}SSH port is NOT set to $ssh_port.${NC}"
fi

# Check running services
running_services=$(systemctl --type=service --state=running)
echo -e "${GREEN}Running services:${NC}"
echo "$running_services"

# Check permissions of critical directories and files
if [ "$(stat -c "%a" /etc)" -eq 700 ] && [ "$(stat -c "%a" /usr/local/etc)" -eq 700 ]; then
    echo -e "${GREEN}Permissions for /etc and /usr/local/etc are set correctly.${NC}"
else
    echo -e "${RED}Permissions for /etc or /usr/local/etc are NOT set correctly.${NC}"
fi

# Check sensitive file permissions
for file in /etc/master.passwd /etc/shadow /etc/gshadow; do
    if [ -e "$file" ]; then
        if [ "$(stat -c "%a" "$file")" -eq 600 ]; then
            echo -e "${GREEN}Permissions for $file are set correctly.${NC}"
        else
            echo -e "${RED}Permissions for $file are NOT set correctly.${NC}"
        fi
    fi
done

# Check if system is updated
if pacman -Q --upgrades > /dev/null; then
    echo -e "${RED}There are updates available.${NC}"
else
    echo -e "${GREEN}System is up to date.${NC}"
fi

echo -e "${GREEN}Validation script execution completed.${NC}"
security_scan
