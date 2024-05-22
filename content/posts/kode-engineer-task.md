---
author: furywizz
title: "Kode Engineer 任务记录"
date: 2022-11-26T15:02:28+08:00
draft: true
ShowToc: true
ShowBreadCrumbs: false
---

####  设置指定的时区（Linux TimeZones Setting）
 使用`timedatectl` 处理
 ``` shell
 timedatectl set-timezone Asia/Shanghai
 ```
#### 创建非登陆用户（Create a Linux User with non-interactive shell）
使用 `adduser` 命令处理，这里另外要求改用户不能拥有shell的交互能力，也就是不能登陆
```shell
sudo adduser user -s /sbin/nologin
```
通过 `cat /etc/passwd` 可以看到最近添加的用户名以及相关的权限信息，大概会是这样 `bind:x:115:118::/var/cache/bind:/usr/sbin/nologin`

#### 替换文本文件中的指定字符串（Linux String Substitute）
```shell
sed -i 's/Random/Marine/' /root/the_name.xml
```
使用sed 命令，替换 the_name.xml 文件中所有的Random字符串为Marine

#### Selinux 安装 （Selinux Installation）
```shell
yum install selinux-policy-targeted
```
SELinux 表示 Security-Enhanced Linux，是内核级别的安全模块

#### Linux 无密码登录（Linux SSH Authentication）
```shell
# 简单点就一路回车，不然就看自己需要了
ssh-keygen -t rsa -b 4096  ## 也可不需要指定长度，看需求

# 这里默认是将 当前用户 .ssh/id_rsa.pub 文件拷贝到目标服务器用户的.ssh/authorized_keys 里
ssh-copy-id  root@192.168.100.10

## 如果你是自定义上边生成的密钥对，那这里copy时候使用 -i 指定公钥路径
ssh-copy-id -i /path/xxxxx.pub root@192.168.100.10



```

#### 2022-12-05: Linux User Files (Linux上的用户文件)

要求移动指定目录下，指定用户的文件到另一个文件夹，在移动过程中需要保持文件夹到结构.    
第一想到的是需要管道命令 `|`把文件一个个copy到指定路径上去，但有另外的点不知道怎么处理，一个是过滤用户，然后是保持文件夹结构。搜索一下，还是容易找到方法。使用find命令通过 -user 参数可以过滤指定用户的文件。而cpio这个命令的确是第一遇到，也是看了别人的答案才了解到的，主要用来做备份用。然后两者通过管道命令连接起来。    
一些参数：
-p或--pass-through 　执行copy-pass模式，略过备份步骤，直接将文件复制到目的目录
-d或--make-directories 　如有需要cpio会自行建立目录。
-m或preserve-modification-time 　不去更换文件的更改时间。
```shell
find . -user kareem|cpio -pdm /blog
```
#### 2022-12-07: Linux run level (Linux运行级别)
目标： 修改系统的默认级别为GUI级别
1. Linux系统的run level 就是在启动的过程中以哪种形态呈现，有点类似与window的启动方式选项。记得好像ubuntu系统启动时候，也有选择，图形化界面或者多用化交互界面
2. 可选的级别，0 停机 1 单用户模式 2 多用户，没有 NFS 3 完全多用户模式 4 没有用到 5 图形界面 6 重新启动 S s Single user mode
3. 有两种方式设置
 ```shell
# 使用init 命令设置默认级别为多用户模式 
init 3 
# 使用systemctl 命令,这个命令更清晰，但是需要指定默认的级别为字符串，需要提前知道。不过终究是用得少。建议使用
# 其他可选之 rescue.target，emergency.target，multi-user.target
systemctl set-default graphical.target

# 获取当前默认的运行级别
systemctl get-default
```
#### 2022-12-08: Create a Cron job (添加一个定时任务)
目标：需要每个5分钟在/tmp/cron_text 文件下写入一个hello   
这个是比较容易的，系统为centos7。唯一要注意的是用户权限，谁写入的任务，就是以对应的用户权限。我这里切换到了root
```shell
# 安装cronie
sudo yum install cronie
# 使用systemctl启动
systemctl start crond && systemctl enable crond
## 添加定时任务
# 1. 打开定时任务编辑器，看交互，指定自己使用的编辑器来编辑（如果有的话）
crontab -e
# 2. 写入定时任务
*/5 * * * * echo hello >> /tmp/cron_text
```

#### 2022-12-09: Linux Collaborative Directories (文件夹权限设置)
目标： 在指定路径下创建一个文件夹，要求root用户和属组内用户有读、写执行权限，其他用户没有权限
```shell
# root用户创建文件夹,-p参数可以创建多集
sudo makedir -p /bob/data/

# 改变文件夹属组,将 /bob/data 以及子文件夹修改为归属 sysops
sudo chgrp -R sysops /bob/data/ 

# 改变权限,root 和属组内用户可以执行读、写、执行操作，其他用户没有权限
sudo chown 770  /bob/data/ 

```

#### 2022-12-12: MariaDB Troubleshooting (MariaDB 文件处理)
目标：mariadb 没能启动，找出原因并让它启动起来
首先使用 systemctl status mariadb 查看状态，的确没起来，也没有明确的错误信息，或者说我看不出来    
然后用 journalctl -u mariadb.service 查看，也没有看懂错误
然后没办法了，直接去社区找答案
结论： 是因为 /var/lib 下的mysql 文件夹需要权限不对。需要使用mysql组和mysql用户运行。
```shell
sudo chown -R mysql:mysql /var/lib/mysql
```