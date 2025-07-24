#!/bin/bash
#
# 文件名: download.sh
# 描述: 下载 ComfyUI 所需的模型文件

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 首先导入配置文件
source "$ROOT_DIR/config/comfyui_config.sh"

# 然后导入初始化脚本
source "$ROOT_DIR/utils/init.sh"

# 初始化环境
init_script

log_info "开始模型下载流程..."

# 确保在正确的 conda 环境中
ensure_conda_env

# 检查并创建模型目录
check_model_dirs() {
    local dirs=(
        "$MODELS_DIR"
        "$MODELS_DIR/checkpoints"
        "$MODELS_DIR/vae"
        "$MODELS_DIR/loras"
        "$MODELS_DIR/controlnet"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_info "创建目录: $dir"
            mkdir -p "$dir"
        fi
    done
}

# 安装下载工具
install_download_tools() {
    log_info "安装模型下载工具..."
    pip install -q huggingface_hub modelscope aria2
    
    # 设置HuggingFace镜像
    export HF_ENDPOINT="https://hf-mirror.com"
}

# 从HuggingFace下载模型
download_huggingface_model() {
    local model_id="$1"
    local filename="$2"
    local target_dir="$3"
    
    log_info "从HuggingFace下载模型: $model_id"
    
    if [ -f "$target_dir/$filename" ]; then
        log_warning "模型文件已存在: $filename"
        return
    fi
    
    huggingface-cli download "$model_id" \
        --local-dir "$target_dir" \
        --include "$filename"
        
    log_info "模型 $filename 下载成功"
}

# 从ModelScope下载模型
download_modelscope_model() {
    local model_id="$1"
    local filename="$2"
    local target_dir="$3"
    
    log_info "从ModelScope下载模型: $model_id"
    
    if [ -f "$target_dir/$filename" ]; then
        log_warning "模型文件已存在: $filename"
        return
    fi
    
    modelscope download --model "$model_id" "$filename" --local_dir "$target_dir"
    
    log_info "模型 $filename 下载成功"
}

# 下载基础模型
download_base_models() {
    log_info "开始下载基础模型..."
    
    # 遍历所有模型配置
    for model_key in "${!MODEL_SOURCES[@]}"; do
        local model_info="${MODEL_SOURCES[$model_key]}"
        
        # 解析模型信息 (格式: platform:model_id:filename:target_subdir)
        IFS=':' read -r platform model_id filename target_subdir <<< "$model_info"
        
        case "$platform" in
            "huggingface")
                if [ "$USE_HUGGINGFACE" = "true" ]; then
                    download_huggingface_model "$model_id" "$filename" "$MODELS_DIR/$target_subdir"
                else
                    log_info "跳过HuggingFace模型: $model_id (USE_HUGGINGFACE=false)"
                fi
                ;;
            "modelscope")
                if [ "$USE_MODELSCOPE" = "true" ]; then
                    download_modelscope_model "$model_id" "$filename" "$MODELS_DIR/$target_subdir"
                else
                    log_info "跳过ModelScope模型: $model_id (USE_MODELSCOPE=false)"
                fi
                ;;
            *)
                log_warning "未知的平台: $platform，跳过模型: $model_id"
                ;;
        esac
    done
}

# 主函数
main() {
    log_info "=== 开始模型下载流程 ==="
    
    # 检查配置文件中的下载开关
    if [ "$DOWNLOAD_MODELS" = "true" ]; then
        log_info "配置文件中 DOWNLOAD_MODELS 为 true，继续下载模型"
    else
        log_info "配置文件中 DOWNLOAD_MODELS 为 false，跳过模型下载"
        log_info "您可以稍后修改配置文件中的 DOWNLOAD_MODELS 为 true 后使用以下命令下载模型："
        echo "bash $WORK_DIR/scripts/download.sh"
        return 0
    fi
    
    check_model_dirs
    install_download_tools || return 1
    download_base_models || return 1
    
    log_info "=== 模型下载完成 ==="
    echo -e "${GREEN}模型保存位置: $MODELS_DIR${NC}"
    return 0
}

# 运行主程序
main