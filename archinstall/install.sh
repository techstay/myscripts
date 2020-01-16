#! /usr/bin/bash

# 本脚本使用EFI模式安装系统，需要虚拟机提前设置成EFI模式
# 本脚本接受两个参数，第一个是用户名，第二个是密码，root密码设置为用户密码

function partition() {
    # 以EFI模式分区
    parted -s /dev/sda mklabel gpt
    parted -s /dev/sda mkpart efi fat32 0% 512M
    parted -s /dev/sda mkpart root btrfs 512M 100%
    parted -s /dev/sda set 1 esp on

    # 格式化分区
    mkfs.fat -F32 /dev/sda1
    mkfs.btrfs -f /dev/sda2
}

function mounting() {
    # 挂载分区
    mount /dev/sda2 /mnt
    mkdir -p /mnt/efi
    mount /dev/sda1 /mnt/efi
}

function install_base() {
    # 添加清华大学镜像源
    sed -i '1i Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

    # 安装基本系统和一些必备软件
    pacstrap /mnt base linux linux-firmware base-devel \
        btrfs-progs \
        networkmanager \
        nano vim \
        man-db man-pages texinfo \
        grub efibootmgr \
        amd-ucode intel-ucode \
        openssh gparted
}

function gen_fstab() {
    # 生成fstab文件
    genfstab -U /mnt >>/mnt/etc/fstab
}

function move_script_to_chroot() {
    # 存放脚本的路径
    CHROOT_SCRIPT_PATH=/opt/configure.sh

    # 下载脚本
    wget https://gitee.com/techstay/myscripts/raw/master/archinstall/configure.sh
    mv configure.sh /mnt$CHROOT_SCRIPT_PATH

    # 允许脚本文件执行
    chmod a+x /mnt$CHROOT_SCRIPT_PATH
}

function post_config() {
    # 进入chroot环境继续配置
    # 三个参数分别是用户名、密码和确认密码
    arch-chroot /mnt $CHROOT_SCRIPT_PATH "$1" "$2" "$3"
    if [ $? ]; then
        rm /mnt$CHROOT_SCRIPT_PATH
        read -rp "安装成功，是否重启虚拟机(successful installation, reboot now)？(y/n):" prompt
        if [ "$prompt" = 'y' ] || [ "$prompt" = 'Y' ]; then
            reboot now
        fi
    else
        echo "安装失败，请手动安装Arch Linux(installation failed, please install manually)"
    fi
}

if [ $# -ne 3 ] && [ $# -ne 0 ]; then
    echo "参数不正确，请输入正确的参数(wrong argument, please try again)"
    exit 1
fi

if [ $# -eq 3 ] && [ "$3" -ne "$2" ]; then
    echo "两次输入密码不一致，请重新输入(password mismatch, please try again)"
    exit 1
fi

partition
mounting
install_base
gen_fstab

if [ $# -eq 3 ]; then
    move_script_to_chroot
    post_config "$1" "$2" "$3"
fi
