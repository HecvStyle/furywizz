---
layout:     post
title:      "docker 知识点"
subtitle:   <由浅入深吃透 Docker>
date:       2024-01-06
author:     "wake"
URL: "/2024/1/6/about-docker/"
image:      ""
categories: [ "Tech"]
tags:
- docker
---

## 1. 了解容器技术原理

### chroot
chroot 意味着切换根目录，有了 chroot 就意味着我们可以把任何目录更改为当前进程的根目录,并且使这个程序不能访问目录之外的其他目录

### Namespace   
Namespace 是 Linux 内核的一项功能，该功能对内核资源进行隔离，使得容器中的进程都可以在单独的命名空间中运行，并且只可以访问当前容器命名空间的资源。Namespace 可以隔离进程 ID、主机名、用户 ID、文件名、网络访问和进程间通信等相关资源

### Cgroups
Cgroups 是一种 Linux 内核功能，可以限制和隔离进程的资源使用情况（CPU、内存、磁盘 I/O、网络等）


### UnionFS
一种通过创建文件层进程操作的文件系统，因此，联合文件系统非常轻快，这是容器镜像分层的基础

## 2.核心概念：镜像、容器、仓库，彻底掌握 Docker 架构核心设计理念  

### 组成
- dockerd 客户端
- containerd 通信层，dockerd 通过grpc调用 containerd
- runC  正则的运行时

## 4. 基本操作
- export 导出容器文件，不管此时该容器是否处于运行中的状态
- import 导入容器，导入后就变成了新的镜像，通过run 命令启动

## Dockerfile 编写最佳实践
- 单一职责
- 提供注释信息
- 保持容器最小化
- 合理选择基础镜像
- 使用 .dockerignore 忽略一些不需要参与构建的文件 (这个用的不多)
- 尽量使用构建缓存
- 正确设置时区
```
## Ubuntu 和Debian 
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "Asia/Shanghai" >> /etc/timezone

## CentOS系统
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
- 最小化镜像层数

## 容器监控

### cadvisor 
只是提供数据源，其原理也是定时读取cgroup下的文件来获取信息（linux 下一起皆文件），所以配合prometheus（集中采集） 使用。


## 