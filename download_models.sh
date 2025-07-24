#!/bin/bash
set -x

# Add '|| true' to the end of every line to prevent a download failure from stopping the build.
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/flux1-dev-fp8-all-in-one.safetensors -d /content/ComfyUI/models/checkpoints -o flux1-dev-fp8-all-in-one.safetensors || true
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/flux-depth-controlnet-v3.safetensors -d /content/ComfyUI/models/xlabs/controlnets -o flux-depth-controlnet-v3.safetensors || true
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/depth_anything_v2_vitl.pth?download=true" -d /content/ComfyUI/custom_nodes/comfyui_controlnet_aux/ckpts/depth-anything/Depth-Anything-V2-Large -o depth_anything_v2_vitl.pth || true

# LoRAs
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_anime_lora.safetensors -d /content/ComfyUI/models/loras -o xlabs_anime.safetensors || true
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_art_lora_comfyui.safetensors -d /content/ComfyUI/models/loras -o xlabs_art.safetensors || true
# ... apply this pattern to all 150+ aria2c commands ...
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_realism_lora_comfyui.safetensors -d /content/ComfyUI/models/loras -o xlabs_realism.safetensors || true
# ... etc.

echo "Finished downloading models. Some may have failed, which is expected."
