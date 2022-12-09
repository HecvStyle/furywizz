---
layout:     post 
title:      "CKAD练习题记录 (六)"
subtitle:   "CKAD练习题记录"
date:       2022-04-19
author:     "Gemini"
URL: "/2022/4/19/cka-practice-6/"
image:      ""
categories: [ "Tech"]
tags:
    - kubernetes
    - cka
---

来源：https://github.com/dgkanatsios/CKAD-exercises

这一节主要是持久化的状态处理，需要能理解容器镜像、pod的关系，以及 pod 的生命周期有一些了解。

放两个官网文档连接参考，这一部分有点没底，需要多加练习

https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-persistent-volume-storage/ 

https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-volume-storage/

1. Create busybox pod with two containers, each one will have the image busybox and will run the 'sleep 3600' command. Make both containers mount an emptyDir at '/etc/foo'. Connect to the second busybox, write the first column of '/etc/passwd' file to '/etc/foo/passwd'. Connect to the first busybox and write '/etc/foo/passwd' file to standard output. Delete pod.

```yaml
## 这是一个 pod 里有两个容器，需要有两个容器有不同的名字
## 定义了一个公共的volume给这两个容器使用，两个容器都能对这个公共 volume 操作，并且相互可见，题目也就是考察这个点
# 生成模板，注意命令一定要放在最后，不然就直接生成了pod
k run bb2 --image busybox --dry-run=client -oyaml  -- bin/sh -c 'sleep 3600'  >bb2.yaml

## 修改模板
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: bb2
  name: bb2
spec:
  containers: # 注意这里用了复数，也就是说容器可以有多个
  - args:
    - bin/sh
    - -c
    - sleep 3600
    image: busybox
    name: bb21
    resources: {}
    volumeMounts: ## 挂载卷也是复数，说明可以挂载多个卷
    - name: myvolume
      mountPath: /etc/foo
  - args: ## 这是第二个容器
    - bin/sh
    - -c
    - sleep 3600
    image: busybox
    name: bb22  ## 注意名字不能相同
    resources: {}
    volumeMounts: ## 这里的意思就是 把名字为 myvolume 这个卷，挂载到 /etc/foo 这个路径下
    - name: myvolume
      mountPath: /etc/foo
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes: # 这里的结构是属于 spec 的子节点，而不是属于 container 子节点，所以两个 container 都可用
  - name: myvolume ## 这个名字会被容器所指定
    emptyDir: {} 
status: {}

## 对指定容器的操作，注意这里的-c 参数，用来指定 pod 里的容器，因为有多个，所以必读单独指定
k exec -it bb2 -c bb22 -- bin/sh

## 这说是要获取/etc/passwd 第一列的信息存入/etc/foo/passwd 文件，题目要求，这个文字处理，我还是蒙圈
cat /etc/passwd | cut -f 1 -d ':' > /etc/foo/passwd 
```

2. Create a PersistentVolume of 10Gi, called 'myvolume'. Make it have accessMode of 'ReadWriteOnce' and 'ReadWriteMany', storageClassName 'normal', mounted on hostPath '/etc/foo'. Save it on pv.yaml, add it to the cluster. Show the PersistentVolumes that exist on the cluster

```yaml
## 这里是申请一个10G 的卷挂载在 hostPath 的/etc/foo 下
## 这里有个大难题，就是没有命令生产模板，解决方式有两种
# 1. 直接去官官网寻找， 2.通过 explain 组装字段，已经明确了资源名称是 PersistentVolume，只是比较耗时
# 这里我就直接去官网找的
# https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume
# 下次尝试自己独立写出来试试，直接使用 pod 模板修改
apiVersion: v1
kind: PersistentVolume
metadata:
  name: myvolume
  labels:
    type: local
spec:
  storageClassName: normal
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
    - ReadWriteMany
  hostPath:
    path: "/etc/foo"
```

3. Create a PersistentVolumeClaim for this storage class, called 'mypvc', a request of 4Gi and an accessMode of ReadWriteOnce, with the storageClassName of normal, and save it on pvc.yaml. Create it on the cluster. Show the PersistentVolumeClaims of the cluster. Show the PersistentVolumes of the cluster

```yaml
### 处理方式和上边的 pv类似，不太熟悉的字段，使用 explain 查找
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
  labels:
    type: local ## 这个 label 要不要都行，主要是拷贝了上面的代码
spec:
  storageClassName: normal
  resources:
    requests:
      storage: 4Gi # 自己写的时候，没有添加 storage 字段，脑抽了
  accessModes:
    - ReadWriteOnce
```

4. Create a busybox pod with command 'sleep 3600', save it on pod.yaml. Mount the PersistentVolumeClaim to '/etc/foo'. Connect to the 'busybox' pod, and copy the '/etc/passwd' file to '/etc/foo/passwd'

```yaml
# 先生产模板
k run busybox-pvc --image busybox -oyaml --dry-run=client -- /bin/sh -c 'sleep 3600'  >busybox-pvc.yaml
# 修改模板，这里有两个点，属于重复的知识了
# 1.容器里需要指定挂载卷路径，使用 volumeMounts
# 2.挂载的卷需要跟容器同级，所以需要在外层定义卷。使用字段 volumes

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox-pvc
  name: busybox-pvc
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - sleep 3600
    image: busybox
    name: busybox-pvc
    resources: {}
    volumeMounts:
      - name: mypvc
        mountPath: /etc/foo
  dnsPolicy: ClusterFirst
  volumes:  ## 自己写的时候，忘了添加外部卷的定义，所以无法创建 pod
  - name: mypvc ## 这是自己定义的，啥名字都行，container 里需要
    persistentVolumeClaim:
      claimName: mypvc ## 这应该保证有这个名字的 pvc
  restartPolicy: Always
status: {}

```

5. Create a busybox pod with 'sleep 3600' as arguments. Copy '/etc/passwd' from the pod to your local folder

```yaml
# 这里我第一考虑是创建模板，然后修改 container 的参数，但是我写错了
...
spec:
  containers:
  - args: ## 这样写是错的，跟题目要求的描述不符，因为这里我还没有理解参数传递这个概念
    - /bin/sh
    - c
    - 'sleep 3600'
  ....  
  
##理解上来说， 使用 -- /bin/sh -c 'sleep 3600' 其实就是3个参数， 其实是类似的
```

```yaml
# 这里是正确的处理
## 最后的双横线表示向容器内传启动参数
k run busybox_sleep --image busybox -oyaml --dry-run=client -- sleep 3600 > busybox_sleep.yam

## 文件拷贝方式，这个以前不太懂，仔细想想，更 docker 命令类似
# busybox-sleep 是pod的名字
k cp busybox-sleep:/etc/passwd ./passwd
```

##### 小结

这一节主要是关于持久化这种带状态资源的处理。pvc 是对 pv 的上层抽象。而直接和 pod 对接。这是一种抽象的概念。k8s中其他资源，都有这种分层的抽象，目的就是屏蔽下层的东西。
