 #!/bin/bash 
# ----------------------------------------------------------------------------
# EC2 Instance Initialization Script for MERN Stack Application
 # 
# This script automatically installs all dependencies required for the 
# backend application deployment on EC2 instances created by the Auto Scaling 
Group.
 # ----------------------------------------------------------------------------- 
# Set up logging to make debugging easier
 # This redirects all output to both a log file and the system console
 exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1 
echo "Starting EC2 initialization script..." 
# ----------------------------------------------------------------------------
# System Updates and Essential Packages
 # ----------------------------------------------------------------------------- 
# Update package list and install essential build tools and utilities
 echo "Updating system packages..." 
apt update -y 
apt install -y git curl unzip tar gcc g++ make 
# ----------------------------------------------------------------------------
# Node.js Installation via NVM
 # ----------------------------------------------------------------------------- 
# Install Node Version Manager (NVM) for the ubuntu user
 # NVM allows installing and managing multiple Node.js versions
 echo "Installing Node.js via NVM..." 
su - ubuntu -c 'curl -o- https://raw.githubusercontent.com/nvm
sh/nvm/v0.39.3/install.sh | bash' 
# Install the latest LTS version of Node.js 
su - ubuntu -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. 
"$NVM_DIR/nvm.sh" && nvm install --lts' 
# Set the installed version as the default 
su - ubuntu -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. 
"$NVM_DIR/nvm.sh" && nvm alias default node' 
2025-05-12
 # ----------------------------------------------------------------------------
# PM2 Installation and Configuration
 # ----------------------------------------------------------------------------- 
# Install PM2 globally for process management
 # PM2 keeps the Node.js application running and restarts it if it crashes
 echo "Installing PM2 globally..." 
su - ubuntu -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. 
"$NVM_DIR/nvm.sh" && npm install -g pm2' 
# Configure PM2 to start on system boot
 echo "Configuring PM2 startup..." 
su - ubuntu -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. 
"$NVM_DIR/nvm.sh" && pm2 startup' 
# Generate and run the startup script with proper permissions 
env PATH=$PATH:/home/ubuntu/.nvm/versions/node/$(su - ubuntu -c 'export 
NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && node 
v')/bin /home/ubuntu/.nvm/versions/node/$(su - ubuntu -c 'export 
NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && node 
v')/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu 
# ----------------------------------------------------------------------------
# Application Setup
 # ----------------------------------------------------------------------------- 
# Create logs directory for the application
 echo "Creating logs directory..." 
su - ubuntu -c 'mkdir -p ~/logs' 
# ----------------------------------------------------------------------------
# AWS CLI Installation
 # ----------------------------------------------------------------------------- 
# Install AWS CLI for S3 operations (uploading frontend to S3)
 echo "Installing AWS CLI..." 
apt install -y awscli 
echo "EC2 initialization script completed!" 