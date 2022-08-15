---
author: furywizz
title: k8s填空
date: 2022-08-15
description: k8s一些学习记录
math: true
draft: false
tags: ["k8s", "学习"]
ShowToc: true
ShowBreadCrumbs: false
---

1. 监控程序Metric-server pod运行异常报：it doesn‘t contain any IP SANs
   
   是双向证书认证的原因，需要metrics-server容器启动参数，添加 kubelet-insecure-tls 参数。参考自https://blog.csdn.net/pop_xiaohao/article/details/120699030

2. 解决自己搭建的k8s 只能本机认证证书问题
   
   ```shell
   rm /etc/kubernetes/pki/apiserver.*
   
   kubeadm init phase certs all --apiserver-advertise-address=0.0.0.0 --apiserver-cert-extra-sans=10.233.0.1,10.0.0.194,127.0.0.1,129.151.217.180
   
   docker rm `docker ps -q -f 'name=k8s_kube-apiserver*'`
   
   systemctl restart kubelet
   ```
   
   参考：
   
   https://stackoverflow.com/questions/46360361/invalid-x509-certificate-for-kubernetes-master