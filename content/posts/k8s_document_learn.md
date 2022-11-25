---
author: furywizz
title: "Kubernetes官方文档学习--概念篇"
date: 2022-11-25T11:58:12+08:00
math: true
tags: ["k8s","kubernetes"]
ShowBreadCrumbs: false
---

## 基础概念
### 概述
Kubernetes 是一个可移植、可扩展的开源平台，用于管理容器化的工作负载和服务，可促进声明式配置和自动化。
### 容器
#### 运行时
- RuntimeClass是为了让pod被指定的运行时来处理，通过在pod 中 runtimeClassName 指定。
- CRI 一套接口定义，谁实现了，谁就可以充当运行时
- Containerd 一种容器运行时，似乎更轻量一些，比docker少了一层调用（dockershim）
#### 生命周期
钩子回调,针对容器的生命周期
- PostStart 这个回调在容器被创建之后立即被执行
- PreStop  在容器因 API 请求或者管理事件（诸如存活态探针、启动探针失败、资源抢占、资源竞争等） 而被终止之前
### 工作负载
#### pod
这是最小的调度单元
#### 资源
1. deploy 使用一组单元的集合
2. replicaset 状态集合，ReplicaSet 的目的是维护一组在任何时候都处于运行状态的 Pod 副本的稳定集合。 因此，它通常用来保证给定数量的、完全相同的 Pod 的可用性。**一般使用deploy代替**
3. StatefulSet 有状态集合
- 需要稳定的网络，持久存储,有序的扩缩容，滚动更新。主要就是围绕 **有序**这个特性
- 删除StatefulSet 并不能保证有序删除，可以通过缩容到0个副本后在来删除实现有序终止副本
- 删除StatefulSet 并不能同时删除pod挂载的volume，需要手动删除
4. DaemonSet 让每个满足条件的节点跑一个守护服务，监控，日志,网络插件等这是经常用的