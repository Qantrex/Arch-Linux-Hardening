# Arch Linux Hardening

## Scripts
### Hardening Script
1. Setting a new root and user password.
2. Installing essential programs (OpenSSH, sudo, git, nmap).
3. Configuring SSH for key-based login, disabling root login, and changing the SSH port.
4. Creating a new user with sudo privileges.
5. Listing and allowing the user to disable unnecessary services.
6. Adjusting permissions on sensitive files and directories.
7. Updating all installed packages.

### Hardening Check Script
1. Checking if the root password is set.
2. Verifying installation of essential programs (OpenSSH, sudo, git, cronie).
3. Ensuring the SSH service is running and root login is disabled.
4. Confirming the specified user exists and is in the wheel group.
5. Checking SSH access restrictions and that password authentication is disabled.
6. Validating the correct SSH port is set.
7. Listing running services.
8. Ensuring correct permissions for critical directories and files.
9. Verifying a daily update job exists.
10. Checking if the system is up to date.

### Execute the Scripts
``` bash
#!/bin/bash
git clone https://github.com/Qantrex/Arch-Linux-Hardening
cd ./Arch-Linux-Hardening
chmod +x ./hardening-check.bash ./hardening.bash
sudo bash -c './hardening.bash; ./hardening-check.bash'
```