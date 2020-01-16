#! /usr/bin/bash

# 必须有两个参数，第一个是用户名，第二个是密码
function set_user() {
    username=$1
    password=$2
    # root密码就是用户密码
    echo -e "$password\n$password" | passwd

    # 创建新用户并添加sudo权限
    useradd -g wheel -m "$username"
    sed -i "s/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers
    echo -e "$password\n$password" | passwd "$username"
}

function set_locale() {
    # 设置时区
    timedatectl set-timezone Asia/Shanghai
    timedatectl set-ntp 1

    # 生成区域信息
    sed -i "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
    sed -i "s/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen
    locale-gen

    # 设置区域
    localectl set-locale zh_CN.UTF-8
    echo "LANG=zh_CN.UTF-8" >/etc/locale.conf
}

function set_network() {
    # 设置主机名
    echo "$username"-pc >/etc/hostname

    # 设置默认hosts
    cat >/etc/hosts <<EOL
# Static table lookup for hostnames.
# See hosts(5) for details.

127.0.0.1   localhost
::1	    localhost
127.0.1.1   $username-pc.localdomain $username-pc

EOL

    # 启动网络服务
    systemctl enable NetworkManager
}

function set_bootloader() {
    # 安装grub引导管理器
    grub-install /dev/sda --efi-directory=/efi
    grub-mkconfig -o /boot/grub/grub.cfg
}

function set_pacman() {
    # 启用pacman颜色提示
    sed -i 's/^#Color/Color/g' /etc/pacman.conf

    # 启用multilib
    cat >>/etc/pacman.conf <<EOL
[multilib]
Include = /etc/pacman.d/mirrorlist

EOL

    # 启用archlinuxcn清华镜像源
    # 这里因为$arch会展开，所以必须转义$字符
    cat >>/etc/pacman.conf <<EOL
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch

EOL
}
function set_other() {
    # 安装ssh
    systemctl enable sshd
}

if [ $# = 3 ] && [ "$2" -eq "$3" ]; then
    set_user "$1" "$2"
    set_locale
    set_network
    set_bootloader
    set_pacman
    set_other
else
    echo "参数错误，脚本停止(wrong argument, script stopped)"
    exit 1
fi
