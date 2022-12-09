---
layout:     post 
title:      "CKAD练习题记录 (三)"
subtitle:   "CKAD练习题记录"
date:       2022-04-08
author:     "Gemini"
URL: "/2022/4/8/cka-practice-3/"
image:      ""
categories: [ "Tech"]
tags:
    - kubernetes
    - cka
---

来源：https://github.com/dgkanatsios/CKAD-exercises

### **part-D: Configuration**

1. Create a configMap called 'options' with the value var5=val5. Create a new nginx pod that loads the value from variable 'var5' in an env variable called 'option'

```yaml
## 这个意思是要将var5 这个配置，放到pod里作为环境变量，变量名为option
## 涉及到知识点上 env 处理，忘记了字段，可以用 k explain 处理
k explain pod.spec.containers.env.valueFrom.configMapKeyRef
    env:
    - name: option
      valueFrom:
        configMapKeyRef:
          name: options
          key: var5


```

2. Create a configMap 'anotherone' with values 'var6=val6', 'var7=val7'. Load this configMap as env variables into a new nginx pod

```yaml
## 这个跟上边那题略有差别，这里是把 k-v 直接作为环境变量了,可以理解为导入外部kv作为pod的环境变量，而上边是指定某一个key 的值
 13     envFrom:
 14     - configMapRef:
 15       name: another

## 差别点就是字段的使用不熟悉
```

3. Create a configMap 'cmvolume' with values 'var8=val8', 'var9=val9'. Load this as a volume inside an nginx pod on path '/etc/lala'. Create the pod and 'ls' into the '/etc/lala' directory

```yaml
## 第一步创建cm没问题
k create cm cmvolume --from-literal var8=val8 --from-literal var9=val9
## 将cm 加载成为volume这个不清楚
## 思考
1. pod需要一个volume，那么我就提前申明一个，在spec 这个层级，因为是container去挂载volume
		## 这里是知识盲点
   1.1 CM可以作为volume的内容（ConfigMap represents a configMap that should populate this volume）
  8 spec:
  9   volumes:
 10   - name: myvolume
 11     configMap:
 12       name: cmvolume
2. volume需要挂载到contaner上，所以在container内部需要申明挂载的路径已经volume的名字
##这个是数组，也就是可以挂载多个volume 的
 17     volumeMounts:
 18     - mountPath: /etc/lala
 19       name: myvolume

## 创建pod也没问题
k exec -it nginx-cm -- sh -c "ls /etc/lala"

## 所以最后的yaml
```

4. Create the YAML for an nginx pod that has the capabilities "NET_ADMIN", "SYS_TIME" added to its single container

```yaml
## 这个意思是这个container容器需要一些能力，按照这个字面意思，我们使用 explain 来分析
1. k explain pod.spec // 这一层没有找到securityContext 字段，因为这个能你是在container 里
2. k explain pod.spec.container // 这里找到了securityContext，
3. k explain pod.spec.container.securityContext // 这一次找到了关键字 capabilities
4. k explain pod.spec.container.securityContext.capabilities // 一层找到了需要的关键字段 add
## 所以yaml 结构
  8 spec:
  9   containers:
 10   - image: nginx
 11     name: nginx-sc
 12     resources: {}
 13     securityContext:
 14       capabilities:
 15         add:
 16         - NET_ADMIN
 17         - SYS_TIME

```

#### 小结

这一小节里，获得了最重要的技巧，就是使用 k explain 命令。k8s 的命令这么多，不可能都记住，而且写yaml也没有自动提示，尤其在终端修改就更难受了。所以一定要巧用 explain命令。但这个命令，也是需要你有一定的基础知识，毕竟你需要的对象信息在哪个方向，是在pod里？还是在container里？所以还是要多练，多看，多学习。