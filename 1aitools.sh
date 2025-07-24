#!/bin/bash
#
# 文件名: aitools.sh
# 原描述: AI For U 主程序，用于管理各种 AI 工具的安装和配置 【cloudstudio平台】
# 原作者: ai来事
# 原创建日期: 2024-11-28
# 修改日期: 2025-04 

# 用法:
# bash aitools.sh

# 导入初始化脚本
source "./utils/init.sh"

# 初始化环境
init_script

# 清屏函数
clear_screen() {
    clear
}

# 显示标题
show_title() {
    echo -e "${CYAN}"
    echo '    _    ___   _____ ___  ____    _   _ '
    echo '   / \  |_ _| |  ___/ _ \|  _ \  | | | |'
    echo '  / _ \  | |  | |_ | | | | |_) | | | | |'
    echo ' / ___ \ | |  |  _|| |_| |  _ <  | |_| |'
    echo '/_/   \_\___| |_|   \___/|_| \_\  \___/ '
    echo -e "${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${BLUE}                AI For U | 人人皆可AI${NC}"
    echo -e "${PURPLE}================================================${NC}"
}

# 显示菜单
show_menu() {
    echo -e "\n${GREEN}请选择要安装的 AI 工具：${NC}"
    echo "----------------------------------------"
    echo "1) ComfyUI    - AI 绘画工作流神器"
    echo "2) Chat TTS   - AI 语音合成工具"
    echo "3) Open WebUI - AI 对话客户端"
    echo "4) 检查安装状态"
    echo "5) 清理安装"
    echo "6) 退出"
    echo "----------------------------------------"
}

# 检查安装状态
check_installation_status() {
    log_info "检查安装状态..."
    
    # 检查 ComfyUI
    if [ -d "$WORK_DIR/$PROJECT_NAME" ]; then
        echo -e "${GREEN}ComfyUI 已安装${NC}"
        echo "安装位置: $WORK_DIR/$PROJECT_NAME"
        
        # 检查环境
        if conda env list | grep -q "^comfyui_env "; then
            echo -e "${GREEN}Conda 环境已创建${NC}"
        else
            echo -e "${RED}Conda 环境未创建${NC}"
        fi
        
        # 检查模型
        if [ -d "$MODELS_DIR/checkpoints" ] && [ "$(ls -A $MODELS_DIR/checkpoints)" ]; then
            echo -e "${GREEN}模型已下载${NC}"
            echo "模型位置: $MODELS_DIR"
        else
            echo -e "${YELLOW}未找到模型文件${NC}"
        fi
    else
        echo -e "${RED}ComfyUI 未安装${NC}"
    fi
}

# 找不到安装脚本提示
not_found_script() {
    log_error "未找到安装脚本: $1"
    echo -e "${BLUE}获取脚本请访问 https://gf.bilibili.com/item/detail/1107198073${NC}"
}

# 清理安装
cleanup_installation() {
    log_warning "此操作将删除所有安装文件和配置"
    read -p "是否继续？(y/n): " confirm
    
    if [ "$confirm" = "y" ]; then
        log_info "开始清理..."
        
        # 删除 conda 环境
        if conda env list | grep -q "^comfyui_env "; then
            conda deactivate
            conda env remove -n comfyui_env -y
        fi
        
        # 删除安装目录
        if [ -d "$WORK_DIR" ]; then
            rm -rf "$WORK_DIR"
        fi
        
        # 删除配置文件
        rm -f "$SCRIPT_DIR/config/comfyui_config.sh"
        
        log_info "清理完成"
    else
        log_info "取消清理"
    fi
}

# 执行选择的操作
execute_choice() {
    case $1 in
        1)
            install_1="comfyui_setup.sh"
            log_info "启动 ComfyUI 安装程序..."
            if [ -f "./scripts/$install_1" ]; then
                log_info "$install_1 已找到"
                bash "./scripts/$install_1"
            else
                not_found_script "$install_1"
            fi
            ;;
        2)
            log_info "启动 Chat TTS 安装程序..."
            log_warning "此功能正在开发中..."
            ;;
        3)
            log_info "启动 Open WebUI 安装程序..."
            if [ -f "./scripts/open-webui_setup.sh" ]; then
                log_info "open-webui_setup.sh 已找到"
                bash "./scripts/open-webui_setup.sh"
            else
                log_error "未找到安装脚本: ./scripts/open-webui_setup.sh"
            fi
            ;;
        4)
            check_installation_status
            ;;
        5)
            cleanup_installation
            ;;
        6)
            log_info "感谢使用 AI For U 安装助手！"
            exit 0
            ;;
        *)
            log_error "无效的选择，请重试"
            ;;
    esac
}

# 主程序循环
main() {
    # 初始化日志
    init_logging
    
    while true; do
        clear_screen
        show_title
        show_menu
        
        echo -e "\n${GREEN}请输入安装编号：${NC}"
        read choice
        
        execute_choice $choice
        
        if [ "$choice" != "6" ]; then
            echo -e "\n${BLUE}按回车键返回主菜单...${NC}"
            read
        fi
    done
}

# 运行主程序
main
