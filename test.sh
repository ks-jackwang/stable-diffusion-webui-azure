#!/bin/bash

# Assign the first parameter to ACTIVEUSER
ACTIVEUSER=$1
token=$2

# Set echo on
set -x
export NEEDRESTART_MODE=a 

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
huggingface-cli download black-forest-labs/FLUX.1-dev/flux1-dev.safetensors --local-dir /github/ComfyUI/models/checkpoints

huggingface-cli logout


# download Pony Realism
# [checkpoints]
cd /github/ComfyUI/models/checkpoints
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