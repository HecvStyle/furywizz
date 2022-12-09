---
author: Gemini
title:  使用Hugo+Caddy搭建个人博客
date: 2022-04-01
subtitle: 记录一些博客搭建过程的思考以及搭建博客的初衷
math: true
categories: [ "Tech"]
tags:
    - Hugo
    - Caddy
URL: "/2022/4/1/hello-world/"
image:  ""
---

### 0x01 初衷

做了这么多年开发，从iOS、Java 、Go总感觉自己少了一点什么。大概就是少了一份对工作的反思和计划吧。

以前也断断续续写过一些，但最后也还是不了了之。这次又决定重新捡起来，是想记录一些工作上的坑，等回头看看自己曾经踩过的坑，挖过坑，能找到些剖析自己的蛛丝马迹。另一方面，远离文字太久了，感觉思想都有一些僵硬了，希望通过写作锻炼自己的思维。

### 0x02 博客基础结构

#### 关于服务器

没错，你猜对了，我是白嫖的甲骨文新加坡的arm服务器。我开通了两个实例，怎么说呢？毕竟免费的，真香！但有一些不安的因素，主要是不知道这个实例哪一天突然就死了。而且新加坡的arm实例，也不是那么容易抢到，听天由命吧。

#### 关于博客搭建

本博客基于Hugo + Candy 搭建。域名解析由cloudflare提供，域名则在namesilo购买。

```dockerfile
## Caddyfile 文件内容
www.furywizz.xyz {
  root * /var/www
  file_server
}

## docker 运行
docker run \
  --name hugo \
  -p 80:80 \
  -p 443:443 \
  -d \
  -v ${PWD}/Caddyfile:/etc/caddy/Caddyfile \
  -v ${PWD}/site:/var/www \
  -v ${PWD}/config:/config \
  -v ${PWD}/data:/data \
  -e TZ=Asia/Shanghai \
```

- 为何Hugo？因为作为一个Go开发者，用Hugo感到亲切
- 为何Candy？因为nginx 麻烦啊。用candy只要提供了域名，自动解决https证书问题。相比nginx，还要自己申请证书，（这坑我熟，这又是另一个故事了）。
- 为何docker？一方面自己喜欢docker这种容器技术，平时工作也有经常用到，所以作为第一考虑选项没毛病。还有一个就是维护起来方便。

#### 博客主题

使用[PaperMod](https://github.com/adityatelange/hugo-PaperMod/)主题，找了一圈，发现这个主题既符比较契合我个人视觉感受，然后也有标签功能，也就没有继续花时间找了。很多时候，我们是不需要最好的，需要的是满足自己需求的，在时间花费和完美最求之间找到一个平衡点。

#### 自动部署

~~部署上通过本地编译，然后将编译后的静态文件push到github。服务端写了一个git pull 脚本，通过crontab每分钟执行，拉取最新静态文件。因为是个人博客，对即时性要求不高。我也看了github action 和github 的webhook，感觉都有点杀鸡用牛刀了。~~

之前用到了两个库，还是太麻烦了。现在服务器安装了Hugo，主动拉去代码编译。因为往后考虑要学习CI/CD，所以现在就按照传统的方式，往后来迭代。

### 0x03 总结

本次主要是水了博客搭建的问题。其实搭建过程，最开始是考虑用nginx，但中间踩了好多坑，当然同时也学习了很多关于nginx的一些知识。最后还是选择了Candy+Docker。主要还是考虑方便和快速这两个因素。

