#!/bin/bash

# 获取脚本所在目录的绝对路径
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
log_info "配置 CloudStudio 环境..."

log_info "步骤 1: 开始设置 CloudStudio 环境..."

# 检查 supervisord.conf 文件是否存在
SUPERVISORD_CONF="$ROOT_DIR/config/supervisord.conf"
if [ ! -f "$SUPERVISORD_CONF" ]; then
    log_error "未找到 supervisord.conf 文件: $SUPERVISORD_CONF"
    exit 1
fi

# 删除 CloudStudio 配置文件
if [ -f /etc/supervisord.conf ]; then
    log_info "删除旧的 supervisord.conf 文件"
    rm /etc/supervisord.conf
fi

# 复制 CloudStudio 配置文件
log_info "复制新的 supervisord.conf 文件"
cp "$SUPERVISORD_CONF" /etc/supervisord.conf || {
    log_error "CloudStudio 配置文件复制失败"
    exit 1
}

# 检查是否复制成功
if [ ! -f /etc/supervisord.conf ]; then
    log_error "CloudStudio 配置文件复制失败"
    exit 1
fi

# 删除旧进程
log_info "清理旧进程..."

# 删除 python3 -u launch_hydit_webui.py进程
if pgrep -f "python3 -u launch_hydit_webui.py" > /dev/null; then
    log_info "停止 launch_hydit_webui.py 进程"
    pkill -f "python3 -u launch_hydit_webui.py"
fi

# 删除 jupyter-lab 进程
if pgrep -f "jupyter-lab" > /dev/null; then
    log_info "停止 jupyter-lab 进程"
    pkill -f "jupyter-lab"
fi

# 删除 sshd 进程
if pgrep -f "sshd" > /dev/null; then
    log_info "停止 sshd 进程"
    pkill -f "sshd"
fi

log_info "步骤 2: CloudStudio 环境设置完成"
