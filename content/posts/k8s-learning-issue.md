---
author: furywizz
title: "k8s折腾记录"
date: 2022-11-22
description: 记录使用k8s中碰到的一些问题
math: true
tags: ["k8s","kubernetes"]
ShowBreadCrumbs: false

---

#### 监控程序Metric-server pod运行异常报：it doesn‘t contain any IP SANs
   
   是双向证书认证的原因，需要metrics-server容器启动参数，添加 kubelet-insecure-tls 参数。参考自https://blog.csdn.net/pop_xiaohao/article/details/120699030

#### 解决自己搭建的k8s 只能本机认证证书问题
   
   ```shell
   rm /etc/kubernetes/pki/apiserver.*
   
   kubeadm init phase certs all --apiserver-advertise-address=0.0.0.0 --apiserver-cert-extra-sans=10.233.0.1,10.0.0.194,127.0.0.1,129.151.217.180
   
   docker rm `docker ps -q -f 'name=k8s_kube-apiserver*'`
   
   systemctl restart kubelet
   ```
   
   参考：
   
   https://stackoverflow.com/questions/46360361/invalid-x509-certificate-for-kubernetes-master
   
   最终还是通过reset集群，再在初始化集群时候去设置  apiserver-cert-extra-sans 参数来解决的
   
   ps:更清晰的处理方式
   [更新Kubernetes APIServer证书 - 腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1692388)


#### k8s 通过端口转发，处理集群内的内部访问服务，非NodePort的方式
   
   1. 使用 kubectl port-forward 命令建立端口转发：
      
      ```shell
      k -n istio-system port-forward services/kiali :20001
      
      # 输出，这是随机可用端口转发
      Forwarding from 127.0.0.1:35149 -> 20001
      Forwarding from [::1]:35149 -> 20001
      
      ## 也可以指定端口,20000 端口流量转到20001上
      k -n istio-system port-forward services/kiali 20000:20001
      ```
      
      kiali service的开放端口是20001。 这里操作端口转发将发往 35149 端口的流量转发到20001 端口上。注意开放35149 端口。
      

   2. 建立本地机器到服务器的端口转发
      
      ```shell
      ssh -i ~/.ssh/your_privite_key -L 35149:localhost:35149 -C -N -l root 138.2.66.15
      
      # 这里localhost后边的35149端口 一定是和第一步里的端口对应的。
      # 而第一个35149则是本地监听端口，可以自行更改
      ```
      
      这里就把发往本地的 35149 端口，通过流量 ssh 连接，转发到了服务器上。这样在远程服务器上，就会把流量发往 localhost:35149。而此时，服务期上也监听35149端口，并将流量转发到了20001 端口服务上。这样最终的结果就是，我在本地请求http://127.0.0.1:35149。就如同在服务上请求 localhost:20001 效果一样。这是服务期上没有浏览器，无法渲染返回值。而我本机则是通过浏览器访问，可以有UI交互。
#### 修改集群的默认namespace
修改kubernetes-admin@kubernetes上下文的默认命名空间    

```kubectl config set-context kubernetes-admin@kubernetes --namespace=kube-system```

参考: [使用kubectl管理kubeconfig配置文件](https://www.jianshu.com/p/3c3ac5762f40)
