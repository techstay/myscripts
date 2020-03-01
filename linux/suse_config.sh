#! /bin/bash

sudo zypper addrepo -f http://mirrors.aliyun.com/opensuse/tumbleweed/repo/oss/ oss
sudo zypper addrepo -f http://mirrors.aliyun.com/opensuse/tumbleweed/repo/non-oss/ nonoss
sudo zypper addrepo -f http://mirrors.aliyun.com/packman/openSUSE_Tumbleweed Packman

# 设置Podman镜像源
cp /etc/containers/registries.conf{,.bak}
sudo tee /etc/containers/registries.conf <<EOF
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "68vapi3g.mirror.aliyuncs.com"
EOF

tee /etc/docker/daemon.json <<EOL
{
    "registry-mirrors": [
        "https://68vapi3g.mirror.aliyuncs.com",
        "https://dockerhub.azk8s.cn"
    ]
}
EOL

# 设置时区
sed -i 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
localectl set-locale zh_CN.UTF-8
echo 'LANG=zh_CN.UTF-8' >/etc/locale.conf
timedatectl set-timezone Asia/Shanghai
