#! /usr/bin/bash

# 本脚本假设你刚刚创建了一个ubuntu 18.04的VPS，并使用root账户登录到系统中，然后准备进行各种配置

# 刷新软件仓库
apt update
apt upgrade

# 设置区域和时间
sed -i 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
localectl set-locale zh_CN.UTF-8
echo 'LANG=zh_CN.UTF-8' >/etc/locale.conf
timedatectl set-timezone Asia/Shanghai

# 安装一些必要的软件
apt install -y man-db git zsh screenfetch vim curl

# 创建新用户
read -rp "请输入用户名：" username
useradd -m -g sudo -s /usr/bin/zsh "$username"
passwd "$username"

# 设置新用户无需密码即可用sudo获取管理员权限
echo "$username ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

# 为新用户创建zsh配置文件

cat >/tmp/temp1666.sh <<EEOOFF
curl -L git.io/antigen >.antigen.zsh

cat >.zshrc <<EOF
source ~/.antigen.zsh

antigen use oh-my-zsh
antigen bundle command-not-found
antigen bundle docker

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions

antigen theme romkatv/powerlevel10k

antigen apply
EOF
EEOOFF

su - "$username" -c 'bash /tmp/temp1666.sh'

rm /tmp/temp1666.sh
