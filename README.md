# myscripts

我的一些shell脚本

## archinstall

Arch Linux虚拟机安装脚本，使用前请务必阅读本部分，同时最好先阅读脚本代码之后再执行。

- 脚本仅支持在虚拟机中以EFI方式安装，虚拟机默认一般使用BIOS方式引导，请手动修改虚拟机以便脚本正常运行。
- 该脚本会清除磁盘上所有空间并重新分区，请在使用前确认磁盘文件是否需要。
- 脚本默认设置的root密码与用户密码相同。

使用方法：

```bash
# 下载脚本文件
wget https://gitee.com/techstay/myscripts/raw/master/archinstall/install.sh

# 自动完成所有配置，密码需要输入两次
bash install.sh yourusername yourpasswd yourpasswd

# 无参数脚本，只完成一部分安装工作，剩下的请手动下载编辑运行configure.sh
bash install.sh

wget https://gitee.com/techstay/myscripts/raw/master/archinstall/configure.sh

cp configure.sh /mnt/opt/
arch-chroot /mnt /opt/configure.sh yourusrname yourpasswd yourpasswd
```

**`install.sh`脚本会下载并运行`configure.sh`，如果希望在运行之前进行设置，请调用无参的`install.sh`，并手动下载编辑运行`configure.sh`。**
