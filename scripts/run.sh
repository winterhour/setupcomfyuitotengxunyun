#!/bin/bash
#
# 文件名: run.sh
# 描述: 启动 ComfyUI 服务和 ngrok 隧道

#
# 依赖:
# - utils/init.sh
# - utils/conda_utils.sh
#
# 用法:
# bash run.sh [port]
#
# 示例:
# bash run.sh 8188
#
# 返回值:
# - 0: 成功
# - 1: 端口被占用
# - 2: 服务启动失败

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 导入初始化脚本
source "$ROOT_DIR/utils/init.sh"

# 初始化环境
init_script

# 检查工作目录
if [ ! -d "$WORK_DIR" ]; then
    log_error "工作目录 $WORK_DIR 不存在"
    exit 1
fi

# 现在可以使用日志函数了
log_info "准备启动服务..."

# 错误处理
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "服务启动失败在第 $line_number 行，退出码：$exit_code"
    exit $exit_code
}

trap 'handle_error $LINENO' ERR

# 确保在正确的 conda 环境中
ensure_conda_env

# 获取端口号
PORT=${1:-8188}


# 安装和配置 ngrok
setup_ngrok() {

'''
    log_info "配置 ngrok 服务..."
    
    # 获取当前用户
    local current_user=$(whoami)
    
    # 检查 ngrok 是否已安装
    if ! command -v ngrok &> /dev/null; then
        log_info "安装 ngrok..."
        bash "$WORK_DIR/scripts/ngrok.sh" install
    fi
    
    # 检查 ngrok 是否已认证
    if ! ngrok config check &>/dev/null; then
        log_warning "ngrok 未配置认证token"
        if [ -n "$NGROK_TOKEN" ]; then
            # 验证 token 格式
            log_info "使用配置文件中的 token 进行认证"
            # 使用动态路径
            if [ -f "/$current_user/.config/ngrok/ngrok.yml" ]; then
                rm "/$current_user/.config/ngrok/ngrok.yml"
            fi
            ngrok config add-authtoken "$NGROK_TOKEN"
        else
            log_error "配置文件中未找到有效的 NGROK_TOKEN"
            echo -e "${BLUE}在 https://dashboard.ngrok.com/get-started/setup/linux 获取 ngrok 认证 token${NC}"
            echo -e "${RED}请输入 ngrok 认证 token: ${NC}"
            read -p "请输入 ngrok 认证 token: " NGROK_TOKEN
            ngrok config add-authtoken "$NGROK_TOKEN"
        fi
    fi
    
'''
    return 0
}

# 启动 ngrok
start_ngrok() {
    local port=$1
    
    log_info "启动 ngrok 隧道..."
    
    # 检查 ngrok 是否已经在运行
    if pgrep -x "ngrok" > /dev/null; then
        log_info "ngrok 已经在运行，正在重启..."
        pkill -f ngrok
        sleep 2
    fi
    
    # 启动新的 ngrok 进程，添加详细日志
    nohup ngrok http "$port" > "$LOG_DIR/ngrok.log" 2>&1 &
    
    # 等待 ngrok 启动并获取 URL
    local max_attempts=30
    local attempt=0
    while ! curl -s http://localhost:4040/api/tunnels | grep -q "public_url"; do
        sleep 1
        ((attempt++))
        if [ $attempt -ge $max_attempts ]; then
            # 如果超时，检查日志文件看是否有错误信息
            if [ -f "$LOG_DIR/ngrok.log" ]; then
                log_error "ngrok 启动失败，错误信息："
                cat "$LOG_DIR/ngrok.log"
            fi
            log_error "ngrok 启动超时"
            return 1
        fi
    done
    
    # 获取并显示 URL
    local url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
    log_info "ngrok 隧道已启动"
    echo "================================================"
    echo -e "${BLUE} $url ${NC}"
    echo "================================================"
    echo -e "${GREEN} 查看日志: ${NC} $LOG_DIR/ngrok.log"
    return 0
}

# 启动 ComfyUI
start_comfyui() {
    local port=$1
    local comfyui_dir="$WORK_DIR/$PROJECT_NAME"
    
    if [ ! -d "$comfyui_dir" ]; then
        log_error "ComfyUI 目录不存在: $comfyui_dir"
        return 1
    fi
    
    log_info "启动 ComfyUI 服务..."
    echo -e "${BLUE} 请打开浏览器访问Ngrok隧道: $url ${NC}"
    cd "$comfyui_dir"
    
    # 添加显存优化参数
    # export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024
    
    # 使用 nohup 在后台运行，添加显存优化参数
    python main.py --port "$port" > "$LOG_DIR/comfyui.log" 2>&1
    
    # 等待服务启动
    local max_attempts=30
    local attempt=0
    while ! curl -s "http://localhost:$port" > /dev/null; do
        sleep 1
        ((attempt++))
        if [ $attempt -ge $max_attempts ]; then
            log_error "ComfyUI 服务启动超时"
            return 1
        fi
    done
    
    log_info "ComfyUI 服务已启动，暴露端口：$port"
    return 0
}

# 主函数
main() {
    log_info "=== 开始启动服务 ==="
    
'''
    # 设置 ngrok
    setup_ngrok || {
        log_error "ngrok 设置失败"
        return 1
    }
    
    # 启动 ngrok
    start_ngrok "$PORT" || {
        log_error "ngrok 启动失败"
        return 1
    }
'''
    
    # 启动 ComfyUI
    log_info "ComfyUI 将在端口 $PORT 上启动"
    start_comfyui "$PORT" || {
        log_error "ComfyUI 启动失败"
        return 1
    }
    
    return 0
}

# 捕获 Ctrl+C
trap 'echo -e "\n${RED}正在关闭服务...${NC}"; pkill -f ngrok; exit 0' INT

# 运行主程序
main