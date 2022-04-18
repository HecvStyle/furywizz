---
author: furywizz
title: CKAD练习题记录(4)
date: 2022-04-18
description: CKA练习记录
math: true
tags: ["CKA", "k8s","学习"]
ShowToc: true
ShowBreadCrumbs: false
---

来源：https://github.com/dgkanatsios/CKAD-exercises

**part-E: Observability**

这部分主要是可观察性，也就是能及时发现pod的问题从而进行处理

1. Modify the pod.yaml file so that liveness probe starts kicking in after 5 seconds whereas the interval between probes would be 5 seconds. Run it, check the probe, delete it.

```yaml
## 最开始没太理解到英文表述意思。简单来说就是容器启动5s后探针开始工作，每两次探测间隔5s。
## 这里可能忘记了具体字段，explain再次用上
k explain pod.spec.containers.livenessProbe
## 使用到 initialDelaySeconds 和 periodSeconds 两个字段
 ...
   livenessProbe:
      initialDelaySeconds: 5
      periodSeconds: 5
      exec:
        command:
        - ls
 ...
```

2. Create an nginx pod (that includes port 80) with an HTTP readinessProbe on path '/' on port 80. Again, run it, check the readinessProbe, delete it

```yaml
# 这个比较容易。可以不需要特意指定pod开放80端口,因为nginx默认是80，而且操作也是pod内部。也不需要开放service。
# 严谨一点，还是用--port 指定下 80
k run nginx1 --image=nginx --port=80 -oyaml --dry-run=client > ttt.yaml
   ... 
    readinessProbe:
      httpGet:
        path: /
        port: 80
   ...

```

3. Lots of pods are running in `qa`,`alan`,`test`,`production` namespaces. All of these pods are configured with liveness probe. Please list all pods whose liveness probe are failed in the format of `<namespace>/<pod name>` per line.

```yaml
# 这个题目有点懵圈，描述上来说，直接用 -A 参数就可以查找所有的namespaces。问题是如果没有liveness probe 失败的模版，
# 这个要怎么才能过滤呢？ 从答案来看，只能自己住了。另外，题目描述是中列出是有格式要求的，是否可以手动来拼接结果？
#### 参考答案并修改
k get events -A|grep -i "Unhealthy" |awk '{print $1,$5}'
```

4. Get CPU/memory utilization for nodes ([metrics-server](https://github.com/kubernetes-incubator/metrics-server) must be running)

```yaml
# 题目本身没问题，但是我的主机只有一个节点，造成一直安装不成功。如果用 minikube 则可以简单开启就好了
minikube addons enable metrics-server # 为minikube添加mertrics 插件
k top nodes # 查看运行状况
```

### 总结

这一小节的题目都不难，主要是熟练度的问题。**最重要的事，巧用explain**

