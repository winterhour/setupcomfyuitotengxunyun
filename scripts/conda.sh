#!/bin/bash
#
# 文件名: conda.sh
# 描述: 设置和管理 Conda 环境

#
# 依赖:
# - utils/init.sh
#
# 用法:
# bash conda.sh
#
# 示例:
# bash conda.sh
#
# 返回值:
# - 0: 成功
# - 1: 环境设置失败

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 首先导入初始化脚本
source "$ROOT_DIR/utils/init.sh"

# 初始化环境
init_script

log_info "步骤 1: 开始设置 Conda 环境..."

# 检查 conda 是否已安装
check_conda() {
    log_info "检查 conda 安装..."
    if ! command -v conda &> /dev/null; then
        log_error "未找到 conda，请先安装 Miniconda 或 Anaconda"
        exit 1
    fi
    log_info "conda 已安装"
}

# 初始化 conda
init_conda() {
    log_info "初始化 conda..."
    
    # 初始化 conda
    eval "$(conda shell.bash hook)"
    conda init bash
    
    # 更新 conda
    log_info "更新 conda..."
    conda update -n base -c defaults conda -y
}

# 创建或更新环境
setup_environment() {
    # 从配置文件中读取环境名称
    local env_name="$CONDA_ENV_NAME"
    log_info "设置 conda 环境: $env_name"
    
    # 如果环境存在，询问是否重新创建
    if conda env list | grep -q "^$env_name "; then
        log_warning "环境 $env_name 已存在"
        echo -e "${YELLOW}是否重新创建环境？(y/n): ${NC}"
        echo "================================================"
        read -p "是否重新创建环境？(y/n): " recreate
        if [ "$recreate" = "y" ]; then
            log_info "删除现有环境..."
            conda deactivate 2>/dev/null || true
            conda env remove -n $env_name -y
        else
            log_info "使用现有环境"
            return 0
        fi
    fi
    
    # 从配置文件中读取 Python 版本
    local python_version="$PYTHON_VERSION"
    
    # 创建新环境
    log_info "创建新的 conda 环境..."
    conda create -n $env_name python=$python_version -y -c conda-forge
    
    if [ $? -eq 0 ]; then
        log_info "conda 环境创建成功"
    else
        log_error "conda 环境创建失败"
        return 1
    fi
}

# 配置环境激活
configure_activation() {
    log_info "配置环境激活..."
    local env_name="$CONDA_ENV_NAME"
    
    # 移除旧的激活命令
    sed -i '/source.*activate.*HunyuanDiT/d' ~/.bashrc
    sed -i '/source.*activate.*comfyui_env/d' ~/.bashrc
    
    # 添加新的激活命令
    echo "source activate $env_name" >> /root/.bashrc
    source /root/.bashrc
    
    # 立即激活环境
    source activate $env_name
    
    # 验证环境
    if [ "$CONDA_DEFAULT_ENV" = "$env_name" ]; then
        log_info "conda 环境已激活"
        return 0
    else
        log_error "conda 环境激活失败"
        return 1
    fi
}

# 主函数
main() {
    log_info "=== 开始设置 Conda 环境 ==="
    
    check_conda
    init_conda
    setup_environment
    configure_activation
    
    if [ $? -eq 0 ]; then
        log_info "=== Conda 环境设置完成 ==="
        echo -e "${BLUE}使用以下命令激活环境：${NC}"
        echo "conda activate $CONDA_ENV_NAME"
        return 0
    else
        log_error "Conda 环境设置失败"
        return 1
    fi
}

# 运行主程序
main

