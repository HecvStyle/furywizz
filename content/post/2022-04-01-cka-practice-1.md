---
layout:     post 
title:      "CKAD练习题记录 (一)"
subtitle:   "CKAD练习题记录"
date:       2022-04-01
author:     "Gemini"
URL: "/2022/4/1/cka-practice-1/"
categories: [ "Tech"]
tags:
    - kubernetes
    - cka
image:      ""
---

来源：https://github.com/dgkanatsios/CKAD-exercises

### **part-A: core_concepts**

Get the YAML for a new ResourceQuota called 'myrq' with hard limits of 1 CPU, 1G memory and 2 pods without

```yaml
## 忘记了怎么使用--hard 的参数使用方式，主要内存的单位
kubectl create quota myrq --hard=cpu=1,memory=1G,pods=2 --dry-run=client -o yaml
```

2. Change pod's image to nginx:1.7.1. Observe that the container will be restarted as soon as the image gets pulled

```yaml
# 这里不能直接使用 k edit 或者其他k apply -f 方式处理，因为是pod，不是deployment 
# kubectl set image POD/POD_NAME CONTAINER_NAME=IMAGE_NAME:TAG
kubectl set image pod/nginx nginx=nginx:1.7.1
```

3. Get nginx pod's ip created in previous step, use a temp busybox image to wget its '/'

```yaml
# --rm 参数需要保持pod 不会立即死去，所以可以加 -it 进入交互式模式，否则会报错

kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- 10.1.1.131:80
```

----

###  part-B: multi_container_pods

1. Create a Pod with two containers, both with image busybox and command "echo hello; sleep 3600". Connect to the second container and run 'ls'

```yaml
# 这个题目起初没看懂，后边看了yaml 文件，才知道可以在spec 的args 里设置两个不同的容器名字
## 1.生成模版，注意这里用的是 /bin/sh -c  方式，而且注意是使用 sh 终端，如果用bash 会出错，因为busybox 里没bash
k run busybox --image=busybox --restart=Never -oyaml --dry-run=client -- /bin/sh -c "echo hello; sleep 3600;" > busybox-2c.yaml
## 2. 修改模版
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - echo hello;sleep 3600;
    image: busybox
    name: busybox
    resources: {}
  - args: ## 这里开始是增加的部分，主要就是args 这个结构，注意这里args是数组，以前没注意
    - /bin/sh
    - -c
    - echo hello;sleep 3600;
    image: busybox
    name: busybox2 ## 这里需要两个容器的名字不同，进入容器使用 -c 参数根据name进入的容器
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}


## 3 进入容器
k exec -it busybox -c busybox2 -- sh
```

2. Create a pod with an nginx container exposed on port 80. Add a busybox init container which downloads a page using "wget -O /work-dir/index.html http://neverssl.com/online". Make a volume of type emptyDir and mount it in both containers. For the nginx container, mount it on "/usr/share/nginx/html" and for the initcontainer, mount it on "/work-dir". When done, get the IP of the created pod and create a busybox pod and run "wget -O- IP"

```yaml
## 分解下题目意思
1. 创建一个nginx 的pod
2. 这个pod 有一个 初始化pod，使用busybox做镜像
3. 初始化pod 使用wge 下载一个网页到 /work-dir/index.html 路径
4. nginx 这个pod 和初始化这个pod 都需要挂在一个volume，只是彼此的路径不同
5. 最后其实就是让nginx的首页变成下载过来的网页。
6. 这里主要考察initContainer 和 volume 挂在两个知识点

## 解题方法
1. 生成nginx 的模版
k run nginx-web --image=nginx --port=80 -oyaml --dry-run=client >nginx-web.yaml

2. 修改模版
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-web
  name: nginx-web
spec:
  initContainers: ## 这是增加的节点，注意是以args 是数组，也就是说可以有多个初始化容器
  - args:
    - /bin/sh
    - -c
    - wget -O /work-dir/index.html http://neverssl.com/online
    image: busybox
    name: box
    volumeMounts: ## 申明挂载的卷，这个卷上和下边的nginx 共用的，这是针对各自的路径上不一样的，类似软连接
      - name: vol
        mountPath: /work-dir
  containers:
  - image: nginx
    name: nginx-web
    ports:
    - containerPort: 80
    resources: {}
    volumeMounts: ## 申明挂载卷，
    - name: vol
      mountPath: /usr/share/nginx/html
  volumes: ## 这是实际的卷
    - name: vol ## 因为两个pod 是在一起的，所以这个volume肯定是相同的节点上。
      emptyDir: {}  ## 这是一个零时卷，生命周期和pod是一起的，重启不会丢失，删除pod也就删除了emptyDir 卷
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


3. 访问路径
## 使用-it 进入交汇时，然后执行 wget-O ip:80 
k run box --image=busybox --restart=Never  --rm -it -- sh
## 或者一次搞定
k run box --image=busybox --restart=Never  --rm -it -- /bin/sh -c "wget -O- IP"
```
