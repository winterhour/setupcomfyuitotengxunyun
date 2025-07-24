'''

#!/bin/bash

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

# 显示使用方法
show_usage() {
    echo "================================================"
    echo "使用方法: bash $0 {install|run|status}"
    echo "================================================"
    echo "命令:"
    echo "  install        - 安装 ngrok"
    echo "  run <port>     - 启动 ngrok 暴露指定端口"
    echo "  status        - 查看 ngrok 状态"
    echo "================================================"
}

# 安装 ngrok
install_ngrok() {
    log_info "开始安装 ngrok..."
    
    # 检查是否已安装
    if command -v ngrok &> /dev/null; then
        log_info "ngrok 已安装"
        ngrok version
        return 0
    fi
    
    # 删除 CUDA 源
    if [ -f /etc/apt/sources.list.d/cuda.list ]; then
        rm -rf /etc/apt/sources.list.d/cuda.list
    fi

    # 更新系统包
    apt update
    apt install -y curl jq
    
    # 安装 ngrok
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
        tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
        echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
        tee /etc/apt/sources.list.d/ngrok.list && \
        apt update && \
        apt install -y ngrok
    
    # 验证安装
    if command -v ngrok &> /dev/null; then
        log_info "ngrok 安装成功"
        
        # 配置 authtoken
        if [ -n "$NGROK_TOKEN" ]; then
            # 获取当前用户
            local current_user=$(whoami)
            local ngrok_config_dir="/home/$current_user/.config/ngrok"
            
            # 如果是 root 用户，使用 root 目录
            if [ "$current_user" = "root" ]; then
                ngrok_config_dir="/root/.config/ngrok"
            fi
            
            if [ -f "$ngrok_config_dir/ngrok.yml" ]; then
                rm "$ngrok_config_dir/ngrok.yml"
            fi
            ngrok config add-authtoken "$NGROK_TOKEN"
        fi
        return 0
    else
        log_error "ngrok 安装失败"
        return 1
    fi
}

# 启动 ngrok
run_ngrok() {
    local port=$1
    
    # 检查端口参数
    if [ -z "$port" ]; then
        log_error "未指定端口号"
        show_usage
        return 1
    fi
    
    # 检查端口是否被占用
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        log_error "端口 $port 已被占用"
        return 1
    fi
    
    # 检查并加载 token
    local config_file="$WORK_DIR/config/comfyui_config.sh"
    if [ -f "$config_file" ]; then
        source "$config_file"
        if [ -n "$NGROK_TOKEN" ]; then
            ngrok config add-authtoken "$NGROK_TOKEN"
        fi
    fi
    
    log_info "启动 ngrok，端口: $port"
    ngrok http "$port"
}

# 检查 ngrok 状态
check_status() {
    log_info "检查 ngrok 状态..."
    
    # 检查 ngrok 进程
    if pgrep -x "ngrok" > /dev/null; then
        log_info "ngrok 正在运行"
        # 获取 ngrok URL
        if curl -s http://localhost:4040/api/tunnels | grep -q "public_url"; then
            local url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
            echo -e "${GREEN}ngrok URL: $url${NC}"
        fi
        
        # 显示配置信息
        local config_file="$WORK_DIR/config/ngrok_config.sh"
        if [ -f "$config_file" ]; then
            echo -e "${BLUE}配置文件: $config_file${NC}"
            if grep -q "NGROK_TOKEN" "$config_file"; then
                echo -e "${GREEN}Token 已配置${NC}"
            else
                echo -e "${YELLOW}Token 未配置${NC}"
            fi
        else
            echo -e "${YELLOW}未找到配置文件${NC}"
        fi
    else
        log_info "ngrok 未运行"
    fi
}

# 主函数
main() {
    case "$1" in
        "install")
            install_ngrok
            ;;
        "run")
            run_ngrok "$2"
            ;;
        "status")
            check_status
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

# 运行主程序
main "$@"

'''