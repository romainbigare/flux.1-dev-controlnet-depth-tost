import os, json, runpod
import random, time
import torch
import numpy as np
import base64
from PIL import Image
import nodes
from nodes import NODE_CLASS_MAPPINGS
from nodes import load_custom_node
from comfy_extras import nodes_custom_sampler
from comfy_extras import nodes_flux
from comfy import model_management
from io import BytesIO

load_custom_node("/content/ComfyUI/custom_nodes/comfyui_controlnet_aux")
load_custom_node("/content/ComfyUI/custom_nodes/x-flux-comfyui")

CheckpointLoaderSimple = NODE_CLASS_MAPPINGS["CheckpointLoaderSimple"]()
# LoraLoader = NODE_CLASS_MAPPINGS["LoraLoader"]()  # ❌ Commented out
XlabsSampler = NODE_CLASS_MAPPINGS["XlabsSampler"]()
VAEDecode = NODE_CLASS_MAPPINGS["VAEDecode"]()
EmptyLatentImage = NODE_CLASS_MAPPINGS["EmptyLatentImage"]()
LoadFluxControlNet = NODE_CLASS_MAPPINGS["LoadFluxControlNet"]()
ApplyFluxControlNet = NODE_CLASS_MAPPINGS["ApplyFluxControlNet"]()
# LoadImage = NODE_CLASS_MAPPINGS["LoadImage"]()  # ❌ Not needed after base64 change
DepthAnythingV2Preprocessor = NODE_CLASS_MAPPINGS["DepthAnythingV2Preprocessor"]()
CLIPTextEncodeFlux = nodes_flux.NODE_CLASS_MAPPINGS["CLIPTextEncodeFlux"]()

with torch.inference_mode():
    unet, clip, vae = CheckpointLoaderSimple.load_checkpoint("flux1-dev-fp8-all-in-one.safetensors")
    controlnet = LoadFluxControlNet.loadmodel(model_name="flux-dev", controlnet_path="flux-depth-controlnet-v3.safetensors")[0]

def closestNumber(n, m):
    q = int(n / m)
    n1 = m * q
    if (n * m) > 0:
        n2 = m * (q + 1)
    else:
        n2 = m * (q - 1)
    if abs(n - n1) < abs(n - n2):
        return n1
    return n2

def decode_base64_image(base64_str):
    image_data = base64.b64decode(base64_str)
    return Image.open(BytesIO(image_data))

@torch.inference_mode()
def generate(input):
    values = input["input"]

    # Load image from base64 instead of URL
    base64_image = values['input_image_check']
    controlnet_image = decode_base64_image(base64_image)
    controlnet_image_width, controlnet_image_height = controlnet_image.size
    controlnet_image_aspect_ratio = controlnet_image_width / controlnet_image_height

    controlnet_strength = values['controlnet_strength']
    final_width = values['final_width']
    final_height = final_width / controlnet_image_aspect_ratio

    positive_prompt = values['positive_prompt']
    negative_prompt = values['negative_prompt']
    seed = values['seed']
    steps = values['steps']
    guidance = values['guidance']

    # lora_strength_model = values['lora_strength_model']
    # lora_strength_clip = values['lora_strength_clip']
    # custom_lora_strength_model = values['custom_lora_strength_model']
    # custom_lora_strength_clip = values['custom_lora_strength_clip']
    # lora_file = values['lora_file']
    # custom_lora_url = values['custom_lora_url']
    # custom_lora_file = download_file(url=custom_lora_url, save_dir='/content/ComfyUI/models/loras')
    # custom_lora_file = os.path.basename(custom_lora_file)

    if seed == 0:
        random.seed(int(time.time()))
        seed = random.randint(0, 18446744073709551615)

    print(seed)

    # custom_lora_unet, custom_lora_clip = LoraLoader.load_lora(unet, clip, custom_lora_file, custom_lora_strength_model, custom_lora_strength_clip)
    # lora_unet, lora_clip = LoraLoader.load_lora(custom_lora_unet, custom_lora_clip, lora_file, lora_strength_model, lora_strength_clip)

    conditioning = CLIPTextEncodeFlux.encode(clip, positive_prompt, positive_prompt, 4.0)[0]
    neg_conditioning = CLIPTextEncodeFlux.encode(clip, negative_prompt, negative_prompt, 4.0)[0]

    controlnet_depth = DepthAnythingV2Preprocessor.execute(np.array(controlnet_image), "depth_anything_v2_vitl.pth", resolution=1024)[0]
    controlnet_condition = ApplyFluxControlNet.prepare(controlnet, controlnet_depth, controlnet_strength)[0]
    latent_image = EmptyLatentImage.generate(closestNumber(final_width, 16), closestNumber(final_height, 16))[0]

    sample = XlabsSampler.sampling(model=unet, conditioning=conditioning, neg_conditioning=neg_conditioning,
                                   noise_seed=seed, steps=steps, timestep_to_start_cfg=1, true_gs=guidance,
                                   image_to_image_strength=0, denoise_strength=1,
                                   latent_image=latent_image, controlnet_condition=controlnet_condition)[0]

    decoded = VAEDecode.decode(vae, sample)[0].detach()
    Image.fromarray(np.array(decoded * 255, dtype=np.uint8)[0]).save("/content/tost_flux_pose_lora.png")

    return {"result": "/content/tost_flux_pose_lora.png", "status": "DONE"}

runpod.serverless.start({"handler": generate})
