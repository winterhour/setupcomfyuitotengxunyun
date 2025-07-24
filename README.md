# setupcomfyuitotengxunyun
在腾讯云上安装ComfyUI

下载安装程序：

git clone https://github.com/winterhour/setupcomfyuitotengxunyun.git

运行安装：

cd setupcomfyuitotengxunyun

bash 1aitools.sh

激活 ComfyUI 的 Conda 环境（例如名为 comfyui_env）

conda activate comfyui_env

ComfyUI启动指定端口：

python /workspace/ComfyUI/main.py --listen 0.0.0.0 --port 8188

--------------

屏蔽了：Ngrok

先不安装CUDA相关内容：回头看看情况再决定


CUDA Toolkit Installer	

Installation Instructions:
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-8


----------------------------------

原作者的安装包：

https://openi.pcl.ac.cn/niubi/ComfyUI.git

https://openi.pcl.ac.cn/niubi/comfyui-manager.git

----------------------------------

**原作者、原信息如下：**

# AI For U 人人皆可Ai

# 免费版一键安装脚本

## 支持平台
- [x] 腾讯 Cloud Studio 【免费T4 16G显存】【[视频介绍](https://www.bilibili.com/video/BV1BJmSYFE2a/)】
- [] Google Colab
- [] Kaggle
- [] 启智免费算力平台 【免费A100 40G显存】【[视频介绍](https://www.bilibili.com/video/BV1an4y1X7h5/)】


## 快速开始【免费版】
### 只 ComfyUI 的安装示范
### 包含 ComfyUI + ComfyUI Manager + Ngrok + 国内环境可安装

1. **克隆仓库**：
    只需运行命令：
    ```bash
    git clone https://github.com/aigem/aitools.git
    ```
    国内环境可用：
    ```bash
    git clone https://openi.pcl.ac.cn/niubi/aitools.git
    ```
    ```bash
    git clone https://gitee.com/fuliai/aitools.git
    ```

    ```bash
    cd aitools && git pull
    ```

## 如何使用ComfyUI [【视频教程】](https://www.bilibili.com/video/BV13UBRYVEmX/)
- 下载模型：
    1. 下载modelscope(https://www.modelscope.cn/models)模型：`bash scripts/download.sh`
    先获取要下载模型的相关信息，然后运行脚本：比如 
    2. 下载huggingface(https://huggingface.co/models)模型：`bash scripts/download.sh`
    先获取要下载模型的相关信息，然后运行脚本：比如 
    3. 【主要使用】aria2下载：请在一键包内说明文件中查看
    - 记得将 hf-mirror.com 替换了 huggingface.co
    - 大家查看 huggingface 模型可以使用 https://hf-mirror.com/models

- 使用模型：
    附赠视频中的workflow文件，是关于Flux redux 最简工作流，使用方法：
    1. 这个workflow文件是基于Flex.1 dev及最新flux Redux的
    2. 使用方法：
    确保有以下模型文件，下载可使用一键包内说明文件的命令进行下载：
    - `models/checkpoints/flux_redux.safetensors`
    - `models/vae/vae_approx-sdxl_v3.safetensors`
    - `models/clip_vision/sigclip_vision_patch14_384.safetensors`
    - `models/style_models/flux1-redux-dev.safetensors`

【[强化版视频教程](https://www.bilibili.com/video/BV13UBRYVEmX/)】
【获取[强化版一键安装脚本](https://gf.bilibili.com/item/detail/1107198073)】

