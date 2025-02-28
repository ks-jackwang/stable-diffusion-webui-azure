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
mkdir ComfyUI
chown $ACTIVEUSER:$ACTIVEUSER ComfyUI
su -c "git clone https://github.com/comfyanonymous/ComfyUI.git" $ACTIVEUSER

# Create a virtual environment and install requirements
su -c "python3 -m venv /github/ComfyUI/venv && \
source /github/ComfyUI/venv/bin/activate && \
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu126 && \
pip install -r /github/ComfyUI/requirements.txt" $ACTIVEUSER
# pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126 && \

# Install ComfyUI Manager
cd /github/ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager

# Create the systemd service file default port 8188
sudo cat <<EOF > /etc/systemd/system/ComfyUI.service
[Unit]
Description=ComfyUI
After=network.target

[Service]
User=$ACTIVEUSER
Group=$ACTIVEUSER
WorkingDirectory=/github/ComfyUI
ExecStart=/github/ComfyUI/venv/bin/python main.py --port 8188
Restart=always
Environment="PATH=/github/ComfyUI/venv/bin:/usr/bin:/usr/local/bin"

[Install]
WantedBy=multi-user.target
EOF
 
# Reload systemd daemon and enable the service
systemctl daemon-reload
systemctl enable ComfyUI.service
systemctl start ComfyUI.service

# reboot