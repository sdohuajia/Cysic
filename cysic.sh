#!/bin/bash

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "1. 部署cysic节点"
        echo "2. 查看cysic节点日志"
        echo "请输入选项（1-2）："
        read choice

        case $choice in
            1)
                deploy_cysic_node
                ;;
            2)
                view_cysic_logs
                ;;
            *)
                echo "无效选项，请输入有效数字！"
                sleep 2
                ;;
        esac
    done
}

# 部署cysic节点函数
function deploy_cysic_node() {
    # 检查是否以 root 权限运行
    if [ "$EUID" -ne 0 ]; then
        echo "请以 root 权限运行此脚本（使用 sudo）"
        exit 1
    fi

    # 更新软件包列表
    echo "更新软件包列表..."
    apt update

    # 升级已安装的软件包
    echo "升级已安装的软件包..."
    apt upgrade -y

    # 安装 Cysic Prover 依赖，包括 screen
    echo "安装 Cysic Prover 依赖..."
    apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen -y

    echo "系统更新和依赖安装完成！"

    # 设置 Cysic Prover
    echo "开始设置 Cysic Prover..."
    # 提示用户输入奖励地址
    echo "请输入你的奖励地址（格式如 0x...）："
    read -r REWARD_ADDRESS
    if [ -z "$REWARD_ADDRESS" ]; then
        echo "错误：奖励地址不能为空！"
        exit 1
    fi

    # 下载并运行 setup_linux.sh
    echo "下载并运行 Cysic Prover 安装脚本..."
    curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh && bash ~/setup_linux.sh "$REWARD_ADDRESS"

    # 使用 screen 启动 Cysic Prover，生成日志
    echo "在 screen 会话 'cysic' 中启动 Cysic Prover..."
    screen -S cysic -dm bash -c "cd ~/cysic-prover/ && bash start.sh > prover.log 2>&1"

    echo "Cysic Prover 设置并启动完成！"
    echo "日志文件生成在 ~/cysic-prover/prover.log"
    echo "使用 'screen -r cysic' 查看会话，或 'screen -ls' 列出会话。"
    echo "按任意键返回主菜单..."
    read -n 1
}

# 查看cysic节点日志函数
function view_cysic_logs() {
    # 日志文件路径，固定为 prover.log
    LOG_FILE="$HOME/cysic-prover/prover.log"

    # 检查日志文件是否存在
    if [ ! -f "$LOG_FILE" ]; then
        echo "错误：未找到日志文件 $LOG_FILE！"
        echo "请确认Cysic节点是否已通过选项1部署，并检查 start.sh 是否生成 prover.log。"
        echo "按任意键返回主菜单..."
        read -n 1
        return
    fi

    echo "正在显示Cysic节点日志（$LOG_FILE）..."
    echo "按 Ctrl+C 返回主菜单"
    echo "================================================================"

    # 使用 tail -f 实时查看 prover.log，不影响 screen 会话
    tail -f "$LOG_FILE"
    # tail 会在用户按 Ctrl+C 后停止，然后返回主菜单
    echo "按任意键返回主菜单..."
    read -n 1
}

# 启动主菜单
main_menu
