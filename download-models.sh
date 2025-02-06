#!/bin/bash
# don't need to use sudo to run this script

# Assign the first parameter to ACTIVEUSER
huggingfacetoken=$1
civitaitoken=$2

# Set echo on
set -x
export NEEDRESTART_MODE=a 

#: << 'COMMENT'
# eval "$(/anaconda3/bin/conda shell.bash hook)"
# conda activate comfyui
source /github/ComfyUI/venv/bin/activate
pip install -U "huggingface_hub[cli]"

# download the models from Huggingface
cd /github/ComfyUI
huggingface-cli login  --token $huggingfacetoken --add-to-git-credential

#download stable-diffusion-3.5-large
# [checkpoints] 
huggingface-cli download stabilityai/stable-diffusion-3.5-large sd3.5_large.safetensors --quiet --local-dir /github/ComfyUI/models/checkpoints
# Text Encoder][clip] 
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/clip_g.safetensors --quiet --local-dir /github/ComfyUI/models
mv /github/ComfyUI/models/text_encoders/clip_g.safetensors /github/ComfyUI/models/clip/clip_g.safetensors
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/clip_l.safetensors --quiet --local-dir /github/ComfyUI/models
mv /github/ComfyUI/models/text_encoders/clip_l.safetensors /github/ComfyUI/models/clip/clip_l.safetensors
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/t5xxl_fp16.safetensors --quiet --local-dir /github/ComfyUI/models
mv /github/ComfyUI/models/text_encoders/t5xxl_fp16.safetensors /github/ComfyUI/models/clip/t5xxl_fp16.safetensors
huggingface-cli download stabilityai/stable-diffusion-3.5-large text_encoders/t5xxl_fp8_e4m3fn.safetensors --quiet --local-dir /github/ComfyUI/models
mv /github/ComfyUI/models/text_encoders/t5xxl_fp8_e4m3fn.safetensors /github/ComfyUI/models/clip/t5xxl_fp8_e4m3fn.safetensors
# [vae]
huggingface-cli download stabilityai/sdxl-vae sdxl_vae.safetensors --quiet --local-dir /github/ComfyUI/models/vae
# [Workflow]
huggingface-cli download stabilityai/stable-diffusion-3.5-large SD3.5L_example_workflow.json --quiet --local-dir /github/ComfyUI/user/default/workflows
huggingface-cli Comfy-Org/stable-diffusion-3.5-fp8 sd3.5-t2i-fp16-workflow.json --quiet --local-dir /github/ComfyUI/user/default/workflows

# download black-forest-labs/FLUX.1-dev flux1-dev.safetensors https://huggingface.co/black-forest-labs/FLUX.1-dev
# [checkpoints] 
huggingface-cli download black-forest-labs/FLUX.1-dev flux1-dev.safetensors --local-dir /github/ComfyUI/models/diffusion_models
# [vae]
huggingface-cli download black-forest-labs/FLUX.1-dev ae.safetensors --local-dir /github/ComfyUI/models/vae
# download black-forest-labs/FLUX.1-schnell flux1-schnell.safetensors https://huggingface.co/black-forest-labs/FLUX.1-schnell
# [checkpoints]
huggingface-cli download black-forest-labs/FLUX.1-schnell flux1-schnell.safetensors --local-dir /github/ComfyUI/models/diffusion_models

# download black-forest-labs/FLUX.1-Fill-dev flux1-fill-dev.safetensors https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev
# [checkpoints]
huggingface-cli download black-forest-labs/FLUX.1-Fill-dev flux1-fill-dev.safetensors --local-dir /github/ComfyUI/models/diffusion_models

# download black-forest-labs/FLUX.1-Redux-dev flux1-redux-dev.safetensors https://huggingface.co/black-forest-labs/FLUX.1-Redux-dev
# [checkpoints]
huggingface-cli download black-forest-labs/FLUX.1-Redux-dev flux1-redux-dev.safetensors --local-dir /github/ComfyUI/models/diffusion_models

# download black-forest-labs/FLUX.1-Depth-dev flux1-depth-dev.safetensors https://huggingface.co/black-forest-labs/FLUX.1-Depth-dev
# [checkpoints]
huggingface-cli download black-forest-labs/FLUX.1-Depth-dev flux1-depth-dev.safetensors --local-dir /github/ComfyUI/models/diffusion_models

# download black-forest-labs/FLUX.1-Canny-dev flux1-canny-dev.safetensors https://huggingface.co/black-forest-labs/FLUX.1-Canny-dev
# [checkpoints]
huggingface-cli download black-forest-labs/FLUX.1-Canny-dev flux1-canny-dev.safetensors --local-dir /github/ComfyUI/models/diffusion_models

# download black-forest-labs/FLUX.1-Depth-dev-lora flux1-depth-dev-lora.safetensors https://huggingface.co/black-forest-labs/FLUX.1-Depth-dev-lora
# [loras]
huggingface-cli download black-forest-labs/FLUX.1-Depth-dev-lora flux1-depth-dev-lora.safetensors --local-dir /github/ComfyUI/models/loras

# download black-forest-labs/FLUX.1-Canny-dev-lora flux1-canny-dev-lora.safetensors https://huggingface.co/black-forest-labs/FLUX.1-Canny-dev-lora
# [loras]
huggingface-cli download black-forest-labs/FLUX.1-Canny-dev-lora flux1-canny-dev-lora.safetensors --local-dir /github/ComfyUI/models/loras



# download comfyanonymous/hunyuan_dit_comfyui hunyuan_dit_1.2.safetensors https://huggingface.co/comfyanonymous/hunyuan_dit_comfyui
# [checkpoints]
huggingface-cli download comfyanonymous/hunyuan_dit_comfyui hunyuan_dit_1.2.safetensors --local-dir /github/ComfyUI/models/checkpoints

huggingface-cli logout
#COMMENT

## download the models from civitai

## Pony Realism v2.2 Main+VAE https://civitai.com/models/372465/pony-realism
# [Checkpoint Merge][vae?] ponyRealism_V22MainVAE.safetensors
cd /github/ComfyUI/models/checkpoints
wget -O ponyRealism_V22MainVAE.safetensors "https://civitai.com/api/download/models/914390?type=Model&format=SafeTensor&size=full&fp=fp16&token=$civitaitoken"


## Pony Diffusion V6 XL https://civitai.com/models/257749/pony-diffusion-v6-xl
# [Checkpoint Trained] ponyDiffusionV6XL_v6StartWithThisOne.safetensors
cd /github/ComfyUI/models/checkpoints
wget -O ponyDiffusionV6XL_v6StartWithThisOne.safetensors "https://civitai.com/api/download/models/290640?type=Model&format=SafeTensor&size=pruned&fp=fp16&token=$civitaitoken"

# [VAE] sdxl_vae.safetensors
cd /github/ComfyUI/models/vae
wget -O sdxl_vae.safetensors "https://civitai.com/api/download/models/290640?type=VAE&format=SafeTensor&size=pruned&fp=fp16&token=$civitaitoken"

### NOT FLUX - PONY WORKFLOWS https://civitai.com/models/1101981/not-flux-pony-workflows?modelVersionId=1237889
# [Workflow] notFLUXPONYWORKFLOWS_v10 (1).zip
cd /github/ComfyUI/user/default/workflows
wget -O notFLUXPONYWORKFLOWS_v10.zip "https://civitai.com/api/download/models/1237889?type=Archive&format=Other&token=$civitaitoken"

##----------------- Download to Run NOT FLUX - PONY WORKFLOWS -----------------##
## Realism_By_Stable_Yogi Pony_V3_VAE  https://civitai.com/models/166609/realismbystableyogi?modelVersionId=992946
# [Checkpoint Trained] realismByStableYogi_ponyV3VAE.safetensors
cd /github/ComfyUI/models/checkpoints
wget -O realismByStableYogi_ponyV3VAE.safetensors "https://civitai.com/api/download/models/992946?type=Model&format=SafeTensor&size=full&fp=fp16&token=$civitaitoken"

## Pony Standard VAE V1.0  https://civitai.com/models/660673/pony-standard-vae
# [vae] ponyStandardVAE_v10.safetensors
cd /github/ComfyUI/models/vae
wget -O ponyStandardVAE_v10.safetensors "https://civitai.com/api/download/models/785437?type=Model&format=SafeTensor&token=$civitaitoken"

## Person Enhancer FLUX style for SDXL/PONY v1.0 FLUXenh4nce https://civitai.com/models/642347/person-enhancer-flux-style-for-sdxlpony?modelVersionId=718487
# [Lora] FLUXEnh4nce.safetensors
cd /github/ComfyUI/models/loras
wget -O FLUXEnh4nce.safetensors "https://civitai.com/api/download/models/718487?type=Model&format=SafeTensor&token=$civitaitoken"

##  Eye catching - sliders / ntcai.xyz v1.0 https://civitai.com/models/225334/eye-catching-sliders-ntcaixyz?modelVersionId=254162
# [Lora] eye_catching.safetensors
cd /github/ComfyUI/models/loras
wget -O eye_catching.safetensors "https://civitai.com/api/download/models/254162?type=Model&format=SafeTensor&token=$civitaitoken"

## ExpressiveH (Hentai LoRa Style) エロアニメ ExpressiveH https://civitai.com/models/341353/expressiveh-hentai-lora-style?modelVersionId=382152
# [Lora] Expressive_H-000001.safetensors
cd /github/ComfyUI/models/loras
wget -O Expressive_H-000001.safetensors "https://civitai.com/api/download/models/382152?type=Model&format=SafeTensor&token=$civitaitoken"

## Midjourney mimic v2.0 https://civitai.com/models/251417/midjourney-mimic?modelVersionId=678485
# [Lora] MJ52_v2.0.safetensors
cd /github/ComfyUI/models/loras
wget -O MJ52_v2.0.safetensors "https://civitai.com/api/download/models/678485?type=Model&token=$civitaitoken"

## Envy Pony Pretty Eyes 01 - Pretty Anime Eyes https://civitai.com/models/393101/envy-pony-pretty-eyes-01-pretty-anime-eyes?modelVersionId=438481
# [Lora] EnvyPonyPrettyEyes01.safetensors
cd /github/ComfyUI/models/loras
wget -O EnvyPonyPrettyEyes01.safetensors "https://civitai.com/api/download/models/438481?type=Model&format=SafeTensor&token=$civitaitoken"

## Negative_&_Positive_Embeddings_By_Stable_Yogi Positive Stable_Yogis_PDXL_+Ve https://civitai.com/models/177792/negativeandpositiveembeddingsbystableyogi?modelVersionId=775151
# [embeddings] Stable_Yogis_PDXL_Positives.safetensors
cd /github/ComfyUI/models/embeddings
wget -O Stable_Yogis_PDXL_Positives.safetensors "https://civitai.com/api/download/models/775151?type=Model&format=SafeTensor&token=$civitaitoken"

## Negative_&_Positive_Embeddings_By_Stable_Yogi Negative able_Yogis_PDXL_Neg https://civitai.com/models/177792/negativeandpositiveembeddingsbystableyogi?modelVersionId=772342
# [embeddings] Stable_Yogis_PDXL_Negatives-neg.safetensors
cd /github/ComfyUI/models/embeddings
wget -O Stable_Yogis_PDXL_Negatives-neg.safetensors "https://civitai.com/api/download/models/772342?type=Negative&format=Other&token=$civitaitoken"

## [TI] EasyNegativeV2 [Textual Inversion Embedding] v2 https://civitai.com/models/100191/ti-easynegativev2-textual-inversion-embedding
# [embeddings] EasyNegativeV2.safetensors
cd /github/ComfyUI/models/embeddings
wget -O EasyNegativeV2.safetensors "https://civitai.com/api/download/models/107234?type=Model&format=SafeTensor&token=$civitaitoken"

## 4x-Ultrasharp 4x-Ultrasharp v1.0 https://civitai.com/models/116225/4x-ultrasharp
# [upscale] 4xUltrasharp_4xUltrasharpV10.pt
cd /github/ComfyUI/models/upscale_models
wget -O 4xUltrasharp_4xUltrasharpV10.pt "https://civitai.com/api/download/models/125843?type=Model&format=PickleTensor&token=$civitaitoken"

##----------------- Download to Run NOT FLUX - PONY WORKFLOWS -----------------##

## Babes_By_Stable_Yogi Pony_V4_FP32_Fix  https://civitai.com/models/174687/babesbystableyogi?modelVersionId=1146884
# [Checkpoint Trained] babesByStableYogi_ponyV4FP32Fix.safetensors
cd /github/ComfyUI/models/checkpoints
wget -O babesByStableYogi_ponyV4FP32Fix.safetensors "https://civitai.com/api/download/models/1146884?type=Model&format=SafeTensor&size=full&fp=fp32&token=$civitaitoken"

## Babes_By_Stable_Yogi Pony_V4_VAE_Fix  https://civitai.com/models/174687/babesbystableyogi?modelVersionId=1146820
# [Checkpoint Trained] babesByStableYogi_ponyV4VAEFix.safetensors
cd /github/ComfyUI/models/checkpoints
wget -O babesByStableYogi_ponyV4VAEFix.safetensors "https://civitai.com/api/download/models/1146820?type=Model&format=SafeTensor&size=pruned&fp=fp16&token=$civitaitoken"

## Realism cinematic photographic style F1D Realism F1D v1.5 https://civitai.com/models/758852/realism-cinematic-photographic-style-f1d
# [Lora] realism style v2.safetensors
cd /github/ComfyUI/models/loras
wget -O realism_style_v2.safetensors "https://civitai.com/api/download/models/953083?type=Model&format=SafeTensor&token=$civitaitoken"

# conda deactivate
