---
author: furywizz
title: Kafka学习
date: 2022-04-07
description: 极客时间Kafka实战专栏学习心得
math: true
draft: false
tags: ["kafka", "学习"]
ShowToc: true
ShowBreadCrumbs: false

---


#### Kafka学习

- Producer 一旦连接到集群中的任一台Broker，就能拿到整个集群的 Broker 信息，所以指定 3～4 台就足以了

- 理想情况下，Consumer 实例的数量应该等于该 Group 订阅主题的分区总数。

