---
author: furywizz
title: docker-compose创建redis cluster
date: 2022-05-06T22:20:53+08:00
description: 使用docker compose 创建集群
math: true
tags: ["redis","docker"]
ShowToc: true
ShowBreadCrumbs: false
---

好久没更新博客了，今天来记录一下使用docker-compose 搭建redis 集群的简单处理

#### 1. 基本环境

- macOS系统
- 安装docker和docker-compose，记得启动docker

#### 2. 目标：

3个master和3个slave节点,部署在同一台机器上，使用不同的端口来区分

#### 3. 配置文件

介于我也是参考别人的，我这里先贴出链接：

https://zhuanlan.zhihu.com/p/415328735

这是我主要参考的文章，之前也参考了其他的文章，但是有一些是不成功的，反正就很飘。

这里我贴出我的node1节点redis.conf配置内容：

```conf
port 6371
cluster-enabled yes
cluster-config-file nodes-6371.conf
cluster-node-timeout 5000
appendonly yes
protected-mode no
## 宿主机IP地址
cluster-announce-ip 192.168.3.179 
cluster-announce-port 6371
cluster-announce-bus-port 16371
```

⚠️

**cluster-announce-ip 这里我填写的是我苹果电脑的IP地址，记得要修改**

其他节点注意修改端口就好，贴出node2节点redis.conf配置内容：

```
port 6372
cluster-enabled yes
cluster-config-file nodes-6372.conf
cluster-node-timeout 5000
appendonly yes
protected-mode no
cluster-announce-ip 192.168.3.179 
cluster-announce-port 6372
cluster-announce-bus-port 16372
```

总共有6个配置文件，对照这里改就好了。

#### 4. Docker-compose 文件

贴出docker-compose 文件

```
version: "3"

# 定义服务，可以多个
services:
  redis-6371: # 服务名称
    image: redis:6.0 # 创建容器时所需的镜像
    container_name: redis-6371 # 容器名称
    restart: always # 容器总是重新启动
    volumes: # 数据卷，目录挂载
      - ./node1/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node1/data:/data
    ports:
      - 6371:6371
      - 16371:16371
    command:
      redis-server /usr/local/etc/redis/redis.conf

  redis-6372:
    image: redis:6.0
    container_name: redis-6372
    volumes:
      - ./node2/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node2/data:/data
    ports:
      - 6372:6372
      - 16372:16372
    command:
      redis-server /usr/local/etc/redis/redis.conf

  redis-6373:
    image: redis:6.0
    container_name: redis-6373
    volumes:
      - ./node3/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node3/data:/data
    ports:
      - 6373:6373
      - 16373:16373
    command:
      redis-server /usr/local/etc/redis/redis.conf

  redis-6374:
    image: redis:6.0
    container_name: redis-6374
    restart: always
    volumes:
      - ./node4/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node4/data:/data
    ports:
      - 6374:6374
      - 16374:16374
    command:
      redis-server /usr/local/etc/redis/redis.conf

  redis-6375:
    image: redis:6.0
    container_name: redis-6375
    volumes:
      - ./node5/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node5/data:/data
    ports:
      - 6375:6375
      - 16375:16375
    command:
      redis-server /usr/local/etc/redis/redis.conf

  redis-6376:
    image: redis:6.0
    container_name: redis-6376
    volumes:
      - ./node6/redis.conf:/usr/local/etc/redis/redis.conf
      - ./node6/data:/data
    ports:
      - 6376:6376
      - 16376:16376
    command:
      redis-server /usr/local/etc/redis/redis.conf
```

⚠️

这里用的 redis:6.0 镜像，为什么？ 因为使用最新的7.0镜像，在使用go-redis 这个框架时候会报错。懒得去处理了，就先直接降级到6.0版本。（当前日期是：2022-05-06）之后跟踪下这个issue。

使用`docker-compose up -d` 命令后台启动服务。这里有很多的映射文件。所有配置文件都放在redis-cluster文件夹下。使用tree 命令查看文件结构：

```
├── docker-compose.yaml
├── node1
│   ├── data
│   └── redis.conf
├── node2
│   ├── data
│   └── redis.conf
├── node3
│   ├── data
│   └── redis.conf
├── node4
│   ├── data
│   └── redis.conf
├── node5
│   ├── data
│   └── redis.conf
└── node6
    ├── data
    └── redis.conf
```

data: 文件夹，用来保存数据的地方

redis.conf: 单节点redis的配置文件，上面已经贴出来了

5. #### 创建集群

   1. 上边通过命令启动各个节点，使用`docker ps|grep redis` 查看下状态是否为 Up。如果没有显示，那就用docker logs <servicename> 来查看启动失败的原因。

   2. 假设已经启动成功，那docker ps 应该有 redis-6371 ... redis-6376  6⃣️个服务。使用 `docker exec -it  redis-6371 /bin/bash` 进入redis-6371 这个节点，其他5个节点也可以，随便选一个就好了。

   3. 因为上面只是启动了6个服务，他们目前还么有啥关系，现在使用redis-cli 命令将他们组成集群:

      ```shell
      redis-cli --cluster create 192.168.3.179:6371 192.168.3.179:6372 192.168.3.179:6373 192.168.3.179:6374 192.168.3.179:6375 192.168.3.179:6376 --cluster-replicas 1
      ```

      ⚠️ 记得替换192.168.3.179为自己宿主机的IP地址，端口是docker-compose文件中配置的

   4. 上面命令执行后，会自动生成配置，看提示，输入yes 就行了。之后在data文件夹下就会生成一些文件。

6. #### 测试

   当然是使用golang啦，使用第三方redis 框架 [go-redis](https://github.com/go-redis/redis)，代码比较简单，直接贴出来：

   ```go
   package main
   
   import (
   	"context"
   	"fmt"
   	"github.com/go-redis/redis/v8"
   	"log"
   	"time"
   )
   
   var clusterClient *redis.ClusterClient
   
   func main() {
   	err := clusterClient.Set(context.Background(), "cnn", "fakenews", 5*time.Minute).Err()
   	if err != nil {
   		log.Printf("%v", err)
   		return
   	}
   
   	v := clusterClient.Get(context.Background(), "test").String()
   	fmt.Printf("获取的值:%v", v)
   }
   
   func init() {
   	log.SetFlags(log.Llongfile | log.Lshortfile)
   	// 连接redis集群
   	clusterClient = redis.NewClusterClient(&redis.ClusterOptions{
   		Addrs: []string{ // 填写master主机,这里如果是本地竹节，可以省去IP
   			":6371",
   			":6372",
   			":6373",
   		},
   		// 建立集群
   		//redis-cli --cluster create 192.168.3.179:6371 192.168.3.179:6372 192.168.3.179:6373 192.168.3.179:6374 192.168.3.179:6375 192.168.3.179:6376 --cluster-replicas 1
   	})
   	// 发送一个ping命令,测试是否通
   	s := clusterClient.Do(context.Background(), "ping").String()
   	fmt.Println(s)
   }
   ```

   ⚠️ 使用Another Redis Desktop Manger 链接集群，记得勾选 **Cluster**选项,不然会有问题

7. #### 总结：

   就是搭建集群踩了一些坑。原本同事已经在公网服务器上搭建了redis的集群，但是只能通过本地访问，我尝试用隧道解决，但还是有问题。虽然可以使用Another Redis Desktop Manger 通过ssh 跳板连接，但是代码处理上没法处理。所以还是决定自己起一套好得多。于是看了很多文章，最后折腾半个下午终于搞定。

   以前一直都是单机redis服务，虽然知道集群服务，但没做深入了解，今天因为搭集群，正好补了一些盲点知识。