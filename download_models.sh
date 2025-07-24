#!/bin/bash
set -x # Optional: This will print each command before it runs, which is useful for debugging.

# Essential Models
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/flux1-dev-fp8-all-in-one.safetensors -d /content/ComfyUI/models/checkpoints -o flux1-dev-fp8-all-in-one.safetensors
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/flux-depth-controlnet-v3.safetensors -d /content/ComfyUI/models/xlabs/controlnets -o flux-depth-controlnet-v3.safetensors
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/depth_anything_v2_vitl.pth?download=true" -d /content/ComfyUI/custom_nodes/comfyui_controlnet_aux/ckpts/depth-anything/Depth-Anything-V2-Large -o depth_anything_v2_vitl.pth

# LoRAs (Over 150 downloads)
# Note: I've removed the `&&` so the script continues even if a file is missing.
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_anime_lora.safetensors -d /content/ComfyUI/models/loras -o xlabs_anime.safetensors
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_art_lora_comfyui.safetensors -d /content/ComfyUI/models/loras -o xlabs_art.safetensors
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_disney_lora_comfyui.safetensors -d /content/ComfyUI/models/loras -o xlabs_disney.safetensors
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_mjv6_lora_comfyui.safetensors -d /content/ComfyUI/models/loras -o xlabs_mjv6.safetensors
# CORRECTED TYPO HERE
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/xlabs_flux_realism_lora_comfyui.safetensors -d /content/ComfyUI/models/loras -o xlabs_realism.safetensors
