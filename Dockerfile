FROM runpod/pytorch:2.2.1-py3.10-cuda12.1.1-devel-ubuntu22.04
WORKDIR /content
ENV PATH="/home/camenduru/.local/bin:${PATH}"

# == Setup System and User ==
RUN adduser --disabled-password --gecos '' camenduru && \
    adduser camenduru sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R camenduru:camenduru /content && \
    chmod -R 777 /content && \
    chown -R camenduru:camenduru /home && \
    chmod -R 777 /home && \
    apt update -y && add-apt-repository -y ppa:git-core/ppa && apt update -y && apt install -y aria2 git git-lfs unzip ffmpeg

USER camenduru

# == Install Critical Dependencies ==
# These are essential, so we use '&&' to ensure they all succeed.
RUN pip install -q numpy opencv-python imageio imageio-ffmpeg ffmpeg-python av runpod \
    xformers==0.0.25 torchsde==0.2.6 einops==0.8.0 diffusers==0.28.0 transformers==4.41.2 accelerate==0.30.1 matplotlib==3.9.1 && \
    git clone https://github.com/comfyanonymous/ComfyUI /content/ComfyUI && \
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux /content/ComfyUI/custom_nodes/comfyui_controlnet_aux && \
    git clone https://github.com/XLabs-AI/x-flux-comfyui /content/ComfyUI/custom_nodes/x-flux-comfyui

# == Download Models (Non-critical) ==
# Copy and run the download script. The build will not fail if a single download fails.
COPY --chown=camenduru:camenduru download_models.sh /content/download_models.sh
RUN chmod +x /content/download_models.sh && /content/download_models.sh

# == Final Setup ==
COPY ./worker_runpod.py /content/ComfyUI/worker_runpod.py
WORKDIR /content/ComfyUI
CMD ["python", "worker_runpod.py"]
