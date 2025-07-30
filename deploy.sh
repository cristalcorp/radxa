#!/bin/bash

set -e

echo "[*] Updating signing keyring..."
keyring="$(mktemp)"
version="$(curl -L https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/VERSION)"
curl -L --output "$keyring" "https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_${version}_all.deb"
sudo dpkg -i "$keyring"
rm -f "$keyring"

echo "[*] Using archive in backports repo..."
[ -f /etc/apt/sources.list.d/bullseye-backports.list ] && \
sudo sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|' /etc/apt/sources.list.d/bullseye-backports.list

echo "[*] Installing basic tools..."
sudo apt update || echo "⚠️ apt update failed, setup still continues..."
sudo apt install -y python3 python3-apt sudo openssh-server

echo "[*] Installing Ansible..."

# Required dependencies
sudo apt install -y software-properties-common gnupg2 python3-pip curl python3-passlib

# Ensure pip is up to date
sudo pip3 install --upgrade pip

# Install Ansible via pip (safer/more up to date than apt on Debian Bullseye)
sudo pip3 install ansible

# Confirm installation
ansible --version && echo "[✓] Ansible installed."


echo "[*] Enabling and starting SSH server..."

sudo systemctl enable ssh
sudo systemctl start ssh

sudo systemctl is-active --quiet ssh && echo "[✓] SSH is active." || echo "[✗] SSH failed to start."

echo "[*] Setup completed. Connect to SSH :"
ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

