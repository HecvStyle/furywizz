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
