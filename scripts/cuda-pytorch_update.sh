#!/bin/bash
#
# 文件名: cuda-pytorch_update.sh
# 描述: 更新 CUDA 和 PyTorch

#
# 依赖:
# - utils/init.sh
#
# 用法:
# bash cuda-pytorch_update.sh
#
# 示例:
# bash cuda-pytorch_update.sh
#
# 返回值:
# - 0: 成功
# - 1: 更新失败

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 首先导入初始化脚本
source "$ROOT_DIR/utils/init.sh"

# 初始化环境
init_script

log_info "开始更新 CUDA 和 PyTorch..."

# 确保在正确的 conda 环境中
ensure_conda_env

# 检查 CUDA 可用性
check_cuda() {
    log_info "检查 CUDA 可用性..."
    
    if ! command -v nvidia-smi &> /dev/null; then
        log_error "未检测到 NVIDIA GPU"
        return 1
    fi
    
    # 显示 CUDA 信息
    nvidia-smi
    return 0
}

# 安装 PyTorch
install_pytorch() {
    log_info "开始安装 PyTorch..."
    
    # 显示当前环境
    if [ "$(conda env list | grep '*' | grep comfyui_env)" ]; then
        log_info "当前环境：comfyui_env"
    else
        log_warning "当前环境：$(conda env list | grep '*' | awk '{print $1}')"
        read -p "是否继续安装 PyTorch？(y/n): " continue_install
        if [ "$continue_install" != "y" ]; then
            log_error "安装已取消"
            exit 1
        fi
    fi

    # 删除 CUDA 源
    if [ -f /etc/apt/sources.list.d/cuda.list ]; then
        rm -rf /etc/apt/sources.list.d/cuda.list
    fi

    # 更新系统包
    apt update
    apt upgrade -y
    apt install -y curl wget

    # 更新cuda toolkits
    pip uninstall torch torchvision torchaudio -y
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i cuda-keyring_1.1-1_all.deb
    apt-get update
    apt-get -y install cuda-toolkit-12-6

    log_info "cuda toolkits 更新完成"
    
    # 安装 PyTorch
    pip install torch==2.4.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    
    # 验证安装
    log_info "验证 PyTorch 安装..."
    python -c "import torch; print(f'PyTorch 版本: {torch.__version__}')"
    python -c "import torch; print(f'CUDA 可用: {torch.cuda.is_available()}')"
    
    # 显示验证结果-python运行部分的内容
    log_info "PyTorch 版本: $(python -c "import torch; print(torch.__version__)")"
    log_info "CUDA 可用: $(python -c "import torch; print(torch.cuda.is_available())")"

    if [ $? -eq 0 ]; then
        log_info "PyTorch 安装成功"
    else
        log_error "PyTorch 安装验证失败"
        return 1
    fi
}

# 主函数
main() {
    log_info "=== 开始 CUDA 和 PyTorch 更新 ==="

    # 提示配置文件 $WORK_DIR/config/comfyui_setup.conf 中的值来决定是否继续更新 CUDA 和 PyTorch
    if [ "$(cat $WORK_DIR/config/comfyui_setup.conf | grep 'CUDA_PYTORCH')" ]; then
        log_info "配置文件中 CUDA_PYTORCH 为 true，继续更新 CUDA 和 PyTorch"
    else
        log_info "跳过 CUDA 和 PyTorch 更新"
        # 返回 0 表示正常退出
        return 0
    fi
    
    check_cuda || return 1
    install_pytorch || return 1
    
    log_info "=== CUDA 和 PyTorch 更新完成 ==="
    return 0
}

# 运行主程序
main
