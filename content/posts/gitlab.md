---
author: furywizz
title: gitlab搭建
date: 2022-11-04T11:20:53+08:00
description: gitlab服务期搭建过程
math: true
tags: ["Linux","arm","gitlab","CI/CD","Docker"]
ShowToc: true
ShowBreadCrumbs: false
---



#### 目标

实现一个使用Go编写的API服务的CI/CD

#### 步骤分解：

1.  基础服务
   
   - 服务功能实现，使用最简单的接口就是httpserver就好
   
   - 使用docker打包镜像
   
   - 使用dockerhub的公共仓库保存镜像
   
   - 使用gitlab平台

2. CI/CD
   
   - build阶段
     
     - 先编译出go二进制包
     
     - 将二进制包打包成docker镜像
     
     - 推送镜像到中央仓库
   
   - deploy阶段
     
     - 部署是另外一台机器
     
     - 先登录到另外一台机器
     
     - 执行docker 命令


