#!/bin/bash

# Assign the first parameter to ACTIVEUSER
ACTIVEUSER=$1

# Set echo on
set -x
export NEEDRESTART_MODE=a 

#install Anaconda
cd /home/$ACTIVEUSER
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
bash ./Anaconda3-2024.10-1-Linux-x86_64.sh -b -p /anaconda3
sudo chown -R $ACTIVEUSER:$ACTIVEUSER /anaconda3
sudo chmod 777 -R /anaconda3
source /anaconda3/bin/activate
/anaconda3/bin/conda init --all
/anaconda3/bin/conda config --set auto_activate_base false
source ./.bashrc

# Set up the ComfyuI
cd /github
mkdir ComfyUI
sudo chown -R $ACTIVEUSER:$ACTIVEUSER ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git

# Create a conda virtual environment
eval "$(/anaconda3/bin/conda shell.bash hook)"
conda create -n comfyui python=3.10.12 -y
conda activate comfyui
conda install pip -y
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simpl
# NVIDIA install pytorch nightly instead which might have performance improvements
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu126
# pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126
pip install -r /github/ComfyUI/requirements.txt
conda deactivate

# Create the systemd service file default port 8188
sudo cat <<EOF > /etc/systemd/system/ComfyUI.service
[Unit]
Description=ComfyUI
After=network.target

[Service]
User=$ACTIVEUSER
Group=$ACTIVEUSER
WorkingDirectory=/github/ComfyUI
ExecStart=/anaconda3/envs/comfyui/bin/python main.py --port 8188
Restart=always
Environment="PATH=/anaconda3/envs/comfyui/bin:/usr/bin:/usr/local/bin"

[Install]
WantedBy=multi-user.target
EOF
 
# Reload systemd daemon and enable the service
sudo systemctl daemon-reload
sudo systemctl enable stable-diffusion-webui.service

sudo reboot