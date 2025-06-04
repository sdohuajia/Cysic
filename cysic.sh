#!/bin/bash

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

# 使用 screen 启动 Cysic Prover
echo "在 screen 会话 'cysic' 中启动 Cysic Prover..."
screen -S cysic -dm bash -c "cd ~/cysic-prover/ && bash start.sh"

echo "Cysic Prover 设置并启动完成！"
echo "使用 'screen -r cysic' 查看会话，或 'screen -ls' 列出会话。"
