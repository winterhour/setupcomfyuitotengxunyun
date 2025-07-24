【通义万相】安装：

插件GGUF安装：

插件VideoHelperSuite的安装：

插件（可选）显示GPU等信息插件安装：

cd custom_nodes

git clone https://github.com/crystian/ComfyUI-Crystools

cd ComfyUI-Crystools

pip install -r requirements.txt

----------------

报错信息：

Error message occurred while importing the 'ComfyUI-VideoHelperSuite' module.

ImportError: libGL.so.1: cannot open shared object file: No such file or directory

解决方法：

卸载当前OpenCV包并安装无头版本（无需图形界面依赖）

pip uninstall opencv-python opencv-python-headless -y

pip install opencv-python-headless

----------------

可能需要安装ffmpeg

云服务器无root权限安装FFmpeg

1.​​下载静态编译包​​：

wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz

​​2.解压到用户目录​​：

tar -xvf ffmpeg-release-amd64-static.tar.xz

mv ffmpeg-*-amd64-static ~/ffmpeg

3.​​配置环境变量​​：

echo 'export PATH="$HOME/ffmpeg:$PATH"' >> ~/.bashrc

source ~/.bashrc

​​4.验证安装​​：

ffmpeg -version

​​优势​​：无需编译，直接使用；静态包已包含所有依赖库

----------------

umt5_xxl_fp8_e4m3fn_scaled.safetensors

放进

ComfyUI\models\clip
还是？？
ComfyUI/models/text_encoders/

cd /workspace/ComfyUI/models/clip

这个不管用，要用萝卜老师的。git clone https://www.modelscope.cn/junweifeng/umt5_xxl_fp8_e4m3fn_scaled.safetensors.git

【原始信息：https://www.modelscope.cn/models/junweifeng/umt5_xxl_fp8_e4m3fn_scaled.safetensors】

----------------

clip_vision_h_fp8_e4m3fn.safetensors

放进

ComfyUI\models\clip_vision

cd /workspace/ComfyUI/models/clip_vision

----------------

wan_2.1_vae_fp8_e4m3fn.safetensors

放进

ComfyUI\models\vae

cd /workspace/ComfyUI/models/vae

----------------

wan2.1的GGUF量化大模型

放进

ComfyUI\models\unet

cd /workspace/ComfyUI/models/unet

可用下载命令：

【图生视频，480P，生成时注意尺寸。选择：https://www.modelscope.cn/models?
libraries=GGUF&name=wan2.1&page=1&tabKey=libraries】

cd /workspace/ComfyUI/models/unet

wget https://www.modelscope.cn/models/city96/Wan2.1-I2V-14B-480P-gguf/resolve/master/wan2.1-i2v-14b-480p-Q4_0.gguf

【文生视频，选择：https://www.modelscope.cn/models/city96/Wan2.1-T2V-14B-gguf/files】

cd /workspace/ComfyUI/models/unet

wget https://www.modelscope.cn/models/city96/Wan2.1-T2V-14B-gguf/resolve/master/wan2.1-t2v-14b-Q4_K_M.gguf


