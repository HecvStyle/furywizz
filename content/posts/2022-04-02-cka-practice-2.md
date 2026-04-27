---
title:      "CKAD练习题记录 (二)"
date:       2022-04-02
categories: [ "Tech"]
tags:
    - kubernetes
    - cka
---

### **part-C: core_concepts**

1. Add a new label tier=web to all pods having 'app=v2' or 'app=v1' labels

```yaml
# 一开始忘记了使用 app in (v1,v2) 这样的语法，改成双引号也是可以识别的
k lable pod tier=web -l 'app in (v1,v2)'
# 顺手了解一下删除label，这个表示删除所有tier1的标签
k label pods tier1- -l tier1
```

2. Add an annotation 'owner: marketing' to all pods having 'app=v2' label

```yaml
# 忘记了添加annotation的单词😳，其实可以从上边的annotation 中得到提示
k annotate pod -l app=v2 owner:maarketing
```

3. Create a pod that will be deployed to a Node that has the label 'accelerator=nvidia-tesla-p100'

```yaml
# 1 先给指定的node加上标签，这一步简单
k label nodes node-20220208 accelerator=nvidia-tesla-p100
# 2 生成pod 模版
k run pod-node --image=nginx -oyaml --dry-run=client >c-pod-node.yaml
# 3 修改模版
# 这里我忘记yaml里指定节点标签的字段

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pod-node
  name: pod-node
spec:
  containers:
  - image: nginx
    name: pod-node
    resources: {}
  nodelSelector: ## 就是添加这个字段结构，属于containers下的属性，必须记住字段名，不要写错了。不然就要去官方文档上找了。费时间
    accelerator: nvidia-tesla-p100
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

4. Update  the nginx image to nginx:1.19.8

```yaml
# 这里是修改deploy 的镜像版本
## 加上 --recode=true 这个参数，这样在 history 的记录中，会有这次操作的记录
k edit deployments.apps deployment3 --recode=true
## 或者直接使用命令,加个recode 好一点
k set image deployment.apps/deployment3 nginx=nginx:1.19.8 --record=true
```

5. autoscale the deployment, pods between 5 and 10, targetting CPU utilization at 80%

```yaml
## 命令没记住格式
k autoscale deploy nginx --min=5 --max=10 --cpu-percent=80
## 这里有问题，如果在deploy中没有指定recourse 的requests 参数，
## 则在获取hpa 时候，无法正确显示 当前的cpu 使用率，显示 unknown/80%
```

6. Create a job named pi with image perl that runs the command with arguments "perl -Mbignum=bpi -wle 'print bpi(2000)'"

```yaml
# 容器内要执行的脚本，可以直接加载最后，用 -- 表示，这里看题时候没有理解清楚
k create job pi --image-perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

7. Create a job but ensure that it will be automatically terminated by kubernetes if it takes more than 30 seconds to execute

```bash
## 参考job文档 https://kubernetes.io/zh/docs/concepts/workloads/controllers/job/
## 一开始思路记得有一个timeout 参数可以使用，结果发现并没有，所以只能在yaml 文件里修改了
# 1. 创建yaml 文件
k create job box --image=busybox -oyaml --dry-run=client  -- /bin/sh -c 'while true; do echo hello; sleep 10;done'
# 2. 修改yaml文件，添加字段
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: box
spec:
  activeDeadlineSeconds: 30 # 添加这个字段，表示
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - while true; do echo hello; sleep 10;done
        image: busybox
        name: box
        resources: {}
      restartPolicy: Never
status: {}
```



8. Create the same job, make it run 5 times, one after the other. Verify its status and delete it

```yaml
## 跟上边操作类似，就是添加另外的字段
.spec.completions: 5  ## 表示要完成5次该任务
```

9. Create the same job, but make it run 5 parallel times

```yaml
## 也和上面类似，只是要添加新字段
.spec.parallelism: 5
```

10. Create a cron job with image busybox that runs on a schedule of "*/1 * * * *" and writes 'date; echo Hello from the Kubernetes cluster' to standard output

```yaml
# cron job 会生成 job，获取日志时候，需要指定通过job 获取。也即是说cron job 是对job 的定时管理。但运行完了，似乎没有pod了
k create cronjob cjbox --image=busybox --schedule="*/1 * * * *" -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster'
```

11. Create a cron job with image busybox that runs every minute and writes 'date; echo Hello from the Kubernetes cluster' to standard output. The cron job should be terminated if it takes more than 17 seconds to start execution after its scheduled time (i.e. the job missed its scheduled time).

    ```yaml
    # 生成模版，记得添加  --restart=Never 参数，避免定时任务被无限重启，因为pod 的重启默认是 Always
    k create cronjob cjbusy --restart=Never --image=busybox --schedule="*/1 * * * *" -oyaml --dry-run=client -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster' > c-cj-busybox.yaml
    # 添加字段 startingDeadlineSeconds
    # 这里如果不知道用什么字段，那就要学会使用 k explain 命令，
    # 一层层去寻找需要的字段
    # eg:
    k explain cronjob # 获取cronjob模版最外层的字段
    k expalin cronjob.spec ## cronjob下，spec节点的字段，这个字段就有我们需要的startingDeadlineSeconds字段解释
    .spec.startingDeadlineSeconds: 17
    
    
    ```

    

12. Create a cron job with image busybox that runs every minute and writes 'date; echo Hello from the Kubernetes cluster' to standard output. The cron job should be terminated if it successfully starts but takes more than 12 seconds to complete execution

```yaml
## 方式和上面一样，只是这次的字段不一样，并且这个层级属于 cronjob.spec.jobTemplate.spec
.spec.jobTemplate.spec.activeDeadlineSeconds: 12
```

