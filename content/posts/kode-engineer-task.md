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
