#!/bin/bash
# use sudo to run this script

# Assign the first parameter to ACTIVEUSER
ACTIVEUSER=$1

# Set echo on
set -x
export NEEDRESTART_MODE=a

# Update and install necessary packages
apt update
apt upgrade -y

# Set up the ComfyuI
cd /github
mkdir Fooocu
chown $ACTIVEUSER:$ACTIVEUSER Fooocu
su -c "git clone https://github.com/lllyasviel/Fooocus.git" $ACTIVEUSER

# Create a virtual environment and install requirements
su -c "python3 -m venv /github/Fooocu/venv && \
source /github/Fooocu/venv/bin/activate && \
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu126 && \
pip install -r /github/ComfyUI/requirements_versions.txt" $ACTIVEUSER

# pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126 && \

# Create the systemd service file default port 8188
sudo cat <<EOF > /etc/systemd/system/Fooocu.service
[Unit]
Description=Fooocu
After=network.target

[Service]
User=$ACTIVEUSER
Group=$ACTIVEUSER
WorkingDirectory=/github/Fooocu
ExecStart=/github/Fooocu/venv/bin/python entry_with_update.py --listen
Restart=always
Environment="PATH=/github/Fooocu/venv/bin:/usr/bin:/usr/local/bin"

[Install]
WantedBy=multi-user.target
EOF
 
# Reload systemd daemon and enable the service
systemctl daemon-reload
systemctl enable Fooocu.service
systemctl start Fooocu.service

# reboot