#!/bin/bash

# File: Automated_Cybersecurity_Setup.sh
# Title: Automated Cybersecurity Setup for Kali Linux
# Description: This script automates the setup of essential cybersecurity tools and configurations on Kali Linux.
# Author: Mohamed Elshaheedy
# License: Free to use and modify

# Log file
LOG_FILE="/var/log/cybersecurity_setup.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to configure UFW (Uncomplicated Firewall)
configure_ufw() {
    log_message "Configuring UFW (Uncomplicated Firewall)..."
    ufw enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    ufw reload
    log_message "UFW configured successfully."
}

# Function to set up Fail2Ban for intrusion detection
setup_fail2ban() {
    log_message "Configuring Fail2Ban for intrusion detection..."
    systemctl enable fail2ban
    systemctl start fail2ban
    log_message "Fail2Ban configured successfully."
}

# Function to run RKHunter for rootkit detection
run_rkhunter() {
    log_message "Scanning for rootkits with RKHunter..."
    rkhunter --check
    log_message "RKHunter scan completed."
}

# Function to run ClamAV antivirus scan
run_clamav() {
    log_message "Running ClamAV antivirus scan..."
    freshclam  # Update virus signatures
    clamscan -r /  # Scan the entire system
    log_message "ClamAV scan completed."
}

# Function to run Lynis for security auditing
run_lynis() {
    log_message "Running security audit with Lynis..."
    lynis audit system
    log_message "Lynis security audit completed."
}

# Update and upgrade the system
log_message "Starting system update and upgrade..."
apt-get update -y && apt-get upgrade -y
if [ $? -eq 0 ]; then
    log_message "System update and upgrade completed successfully."
else
    log_message "Error: System update and upgrade failed."
    exit 1
fi

# Install essential cybersecurity tools
log_message "Installing essential cybersecurity tools..."
tools=(
    "nmap"          # Network scanner
    "wireshark"     # Network protocol analyzer
    "john"          # Password cracker
    "hydra"         # Login cracker
    "metasploit-framework" # Penetration testing framework
    "aircrack-ng"   # Wireless network security tool
    "burpsuite"     # Web vulnerability scanner
    "sqlmap"        # SQL injection tool
    "nikto"         # Web server scanner
    "gobuster"      # Directory/file brute-forcer
    "fail2ban"      # Intrusion prevention software
    "ufw"           # Uncomplicated Firewall
    "clamav"        # Antivirus software
    "rkhunter"      # Rootkit hunter
    "lynis"         # Security auditing tool
)

for tool in "${tools[@]}"; do
    apt-get install -y "$tool"
    if [ $? -eq 0 ]; then
        log_message "Installed $tool successfully."
    else
        log_message "Error: Failed to install $tool."
    fi
done

# Configure UFW firewall
configure_ufw

# Set up Fail2Ban
setup_fail2ban

# Run rootkit hunter
run_rkhunter

# Run ClamAV scan
run_clamav

# Run Lynis audit
run_lynis

# Harden SSH configuration
log_message "Hardening SSH configuration..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
log_message "SSH configuration hardened."

# Set up automatic security updates
log_message "Setting up automatic security updates..."
apt-get install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
log_message "Automatic security updates configured."

# Clean up unused packages
log_message "Cleaning up unused packages..."
apt-get autoremove -y
apt-get autoclean -y
log_message "System cleanup completed."

# Completion message
echo "###########################################################"
echo "# Automated Cybersecurity Setup for Kali Linux Completed! #"
echo "###########################################################"
log_message "Automated cybersecurity setup completed successfully."