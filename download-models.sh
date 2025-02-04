#!/bin/bash

# Assign the first parameter to ACTIVEUSER
token=$1

# Set echo on
set -x
export NEEDRESTART_MODE=a 

eval "$(/anaconda3/bin/conda shell.bash hook)"
conda activate comfyui
pip install -U "huggingface_hub[cli]"

# download the models from Huggingface
cd /github/ComfyUI
huggingface-cli login  --token $token --add-to-git-credential

#download stable-diffusion-3.5-large
# [checkpoints] 
huggingface-cli download stabilityai/stable-diffusion-3.5-large sd3.5_large.safetensors --quiet --local-dir /github/ComfyUI/models/checkpoints
# Text Encoder][clip] 
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/clip_g.safetensors --quiet --local-dir /github/ComfyUI/models
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/clip_l.safetensors --quiet --local-dir /github/ComfyUI/models
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/t5xxl_fp16.safetensors --quiet --local-dir /github/ComfyUI/models

# download FLUX.1-dev/flux1-dev.safetensors
# [checkpoints] 
huggingface-cli download black-forest-labs/FLUX.1-dev flux1-dev.safetensors --local-dir /github/ComfyUI/models/checkpoints

huggingface-cli logout
# download the models from civitai
# download Pony Realism
# [checkpoints]
cd /github/ComfyUI/models/checkpoints
wget “https://civitai.com/api/download/models/914390?type=Model&format=SafeTensor&size=full&fp=fp16&token=$token”

# download Pony Realism
# Realism cinematic photographic style F1D
# Fooocus

conda deactivate
