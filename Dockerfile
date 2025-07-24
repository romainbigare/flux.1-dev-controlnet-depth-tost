# Use the official RunPod PyTorch image
FROM runpod/pytorch:2.2.1-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set the working directory
WORKDIR /content

# Install all dependencies as root to ensure a single, consistent environment
RUN apt-get update -y && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get install -y --no-install-recommends aria2 git git-lfs unzip ffmpeg && \
    # Upgrade pip and install Python packages directly into the system environment
    # Pinning numpy to a known compatible version adds extra stability.
    pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir \
        numpy==1.26.4 \
        opencv-python imageio imageio-ffmpeg ffmpeg-python av runpod \
        xformers==0.0.25 torchsde==0.2.6 einops==0.8.0 \
        diffusers==0.28.0 transformers==4.41.2 accelerate==0.30.1 matplotlib==3.9.1 && \
    # Clean up apt cache to reduce image size
    rm -rf /var/lib/apt/lists/*

# Clone the necessary repositories
RUN git clone https://github.com/comfyanonymous/ComfyUI /content/ComfyUI && \
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux /content/ComfyUI/custom_nodes/comfyui_controlnet_aux && \
    git clone https://github.com/XLabs-AI/x-flux-comfyui /content/ComfyUI/custom_nodes/x-flux-comfyui

# Download models
COPY download_models.sh /content/download_models.sh
RUN chmod +x /content/download_models.sh && /content/download_models.sh

# Set up the worker
COPY ./worker_runpod.py /content/ComfyUI/worker_runpod.py
WORKDIR /content/ComfyUI

# Run the application
CMD ["python", "worker_runpod.py"]
