#!/bin/bash

# Assign the first parameter to ACTIVEUSER
ACTIVEUSER=$1
token=$2

# Set echo on
set -x
export NEEDRESTART_MODE=a 

# Update and install necessary packages
apt update
apt upgrade -y
apt install -y ubuntu-drivers-common wget
ubuntu-drivers install

# Install CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
apt install -y ./cuda-keyring_1.1-1_all.deb
apt update
apt -y install cuda-toolkit-12-5 git python3 build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev python3-pip python3-venv


# Set up the stable diffusion web UI
cd /
mkdir github
chown $ACTIVEUSER:$ACTIVEUSER github
cd github
mkdir stable-diffusion-webui
chown $ACTIVEUSER:$ACTIVEUSER stable-diffusion-webui
su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" $ACTIVEUSER

# Create a virtual environment and install requirements
su -c "python3 -m venv /github/stable-diffusion-webui/venv && source /github/stable-diffusion-webui/venv/bin/activate && pip install -r /github/stable-diffusion-webui/requirements.txt" $ACTIVEUSER

# Create the systemd service file default port 8760
cat <<EOF > /etc/systemd/system/stable-diffusion-webui.service
[Unit]
Description=Stable Diffusion Web UI
After=network.target

[Service]
User=$ACTIVEUSER
Group=$ACTIVEUSER
WorkingDirectory=/github/stable-diffusion-webui
ExecStart=/github/stable-diffusion-webui/webui.sh
Restart=always
Environment="PATH=/usr/bin:/usr/local/bin:/github/stable-diffusion-webui/venv/bin"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon and enable the service
systemctl daemon-reload
systemctl enable stable-diffusion-webui.service

#install Anaconda
cd /home/$ACTIVEUSER
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
bash ./Anaconda3-2024.10-1-Linux-x86_64.sh -b -p /anaconda3
chown -R $ACTIVEUSER:$ACTIVEUSER /anaconda3
chmod 777 -R /anaconda3
source /anaconda3/bin/activate
su -c "/anaconda3/bin/conda init --all" $ACTIVEUSER
su -c "/anaconda3/bin/conda config --set auto_activate_base false" $ACTIVEUSER
source ./.bashrc

# Set up the ComfyuI
cd /github
mkdir ComfyUI
chown $ACTIVEUSER:$ACTIVEUSER ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git

# Create a conda virtual environment
su -c "conda create -n comfyui python=3.10.12 -y && \
conda activate comfyui && \
conda install pip -y && \
conda install pip3 -y && \
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simpl && \
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu126 && \
pip install -r /github/ComfyUI/requirements.txt" $ACTIVEUSER

# pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126 && \

# download the models
cd /github/ComfyUI
pip install -U "huggingface_hub[cli]"
huggingface-cli login  --token $token --add-to-git-credential

#download stable-diffusion-3.5-large
# [checkpoints] 
huggingface-cli download stabilityai/stable-diffusion-3.5-large sd3.5_large.safetensors --quiet --local-dir /github/ComfyUI/models/checkpoints
# Text Encoder][clip] 
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/clip_g.safetensors --quiet --local-dir /github/ComfyUI/models/clip
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/clip_l.safetensors --quiet --local-dir /github/ComfyUI/models/clip
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/t5xxl_fp16.safetensors --quiet --local-dir /github/ComfyUI/models/clip

# download FLUX.1-dev/flux1-dev.safetensors
# [checkpoints] 
huggingface-cli download black-forest-labs/FLUX.1-dev/flux1-dev.safetensors

huggingface-cli logout


# download Pony Realism
# [checkpoints]
wget “https://civitai.com/api/download/models/914390?type=Model&format=SafeTensor&size=full&fp=fp16&token=$token”







# Create the systemd service file default port 8188
cat <<EOF > /etc/systemd/system/ComfyUI.service
[Unit]
Description=ComfyUI
After=network.target

[Service]
User=$ACTIVEUSER
Group=$ACTIVEUSER
WorkingDirectory=/github/ComfyUI
ExecStart=/github/ComfyUI/main.py
Restart=always
Environment="PATH=/usr/bin:/usr/local/bin:/github/anaconda3/envs/comfyui/bin"

[Install]
WantedBy=multi-user.target
EOF
 
# Reload systemd daemon and enable the service
systemctl daemon-reload
systemctl enable stable-diffusion-webui.service

reboot