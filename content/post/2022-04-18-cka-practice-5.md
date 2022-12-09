---
layout:     post 
title:      "CKAD练习题记录 (五)"
subtitle:   "CKAD练习题记录"
date:       2022-04-18
author:     "Gemini"
URL: "/2022/4/18/cka-practice-5/"
image:      ""
categories: [ "Tech"]
tags:
    - kubernetes
    - cka
---

**part-F: Services and Networking **

1. Create a deployment called foo using image 'dgkanatsios/simpleapp' (a simple server that returns hostname) and 3 replicas. Label it as 'app=foo'. Declare that containers in this pod will accept traffic on port 8080 (do NOT create a service yet)

```yaml
## dgkanatsios/simpleapp 这个镜像在 arm 机器上不支持，所以deployment 启动后所有pod 一直报错，放在 mac 虚拟机上就没问题了
## 这里签到不要创建 service，所以用 --port 指定开放的端口而不能用 expose
## 如果使用create 会自动添加 label，格式位 app={deplyname}。所以可以不需要当对给 deployment 添加标签
k create deployment foo --image dgkanatsios/simpleapp --replicas 3 --port 8080
k label deployments.apps foo app=foo --overwrite # overwrite 强制更新标签位指定的值，否则对已存在的标签，改命令会报错

```

2. Create a service that exposes the deployment on port 6262. Verify its existence, check the endpoints

```yaml
## 这个没看之前完全没思路，其实很简单，只要将 deployment 暴露6262端口，并将端口映射到后端的8080
kubectl expose deploy foo --port=6262 --target-port=8080
```

3. Create an nginx deployment of 2 replicas, expose it via a ClusterIP service on port 80. Create a NetworkPolicy so that only pods with labels 'access: granted' can access the deployment and apply it

```yaml
## 这题主要是考察网络限制
## 1.要建立2个副本的 deploy,并通过 service 暴露80 端口

kubectl create deployment nginx --image=nginx --replicas=2
kubectl expose deployment nginx --port=80

## 2.需要建立个网络策略，只允许带有指定标签的 pod 才能访问。
##   这是一个单独的资源，不是 pod 或者 service 的属性

kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: access-nginx # pick a name
spec:
  podSelector:
    matchLabels:
      app: nginx # selector for the pods
  ingress: # allow ingress traffic
  - from:
    - podSelector: # from pods
        matchLabels: # with this label
          access: granted


kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- http://nginx:80 --timeout 2   ## 这个会超时
kubectl run busybox --image=busybox --rm -it --restart=Never --labels=access=granted -- wget -O- http://nginx:80 --timeout 2 ## 这个正常，因为满足了 label 条件
```

