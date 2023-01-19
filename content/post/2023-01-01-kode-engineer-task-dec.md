---
layout:     post
title:      "Kode Engineer 1月任务记录 （持续...）"
subtitle:   "记录1月 kode Engineer任务"
date:       2023-01-01
author:     "Gemini"
URL: "/2023/1/1/kode-engineer-task-dec/"
image:      ""
categories: [ "Tech"]
tags:
- kodeKloud
---

#### 2023-01-05: Web服务器的安全配置（Web Server Security）
目标： 1. 隐藏apache 服务器的版本信息 2.指定路径`/media`下的文件列表不能显示出来
```shell
# 主要也是修改apache的服务配置文件
vi /etc/httpd/conf/httpd.conf

# 删除文件结构的索引,
`Options indexes FollowSymLinks`  -> `Options FollowSymLinks` 

# 添加如下内容来关闭版本信息
ServerTokens Prod
ServerSignature Off

# **需要重启服务生效**
```

#### 2023-01-07: 配置nginx的SSL（Setup SSL for Nginx）
目标： 配置nginx的ssl 服务
```shell
# 这个虽然不熟，但多少是知道一点，以前也配置过环境
# 修改默认配置文件
vi /etc/nginx/nginx.conf
 # 修改服务器地址
server_name   -> server_name 172.16.238.12

#开启  Settings for a TLS enabled server 下被注释但服务配置

# 修改证书路径配置,具体路径看实际情况
ssl_certificate "/etc/pki/CA/certs/nautilus.crt";
ssl_certificate_key "/etc/pki/CA/private/nautilus.key";

# 修改网站的文件路径
 root      /usr/xxxx1/xxxx2/html;
 
# 重启nginx服务
systemctl restart nginx
```

#### 2023-01-09: 使用Linux的GPG 加密（Linux GPG Encryption）
目标：使用gpg 和已经指定的密钥加密和解密指定的文件
```shell
# 倒入已经指定的密钥对
gpg --import public_key.asc
gpg --import private_key.asc

# 加密文件 -r 参数附带信息， --armor 让文件打开后以ascii 显示,输入文件用 -o 参数指定
gpg --encrypt -r kodekloud@kodekloud.com --armor < encrypt_me.txt  -o encrypted_me.asc

# 解密文件，这里有用户交互，密钥为`kodekloud`,在加密时候也可以指定
gpg --decrypt decrypt_me.asc > decrypted_me.txt
```
这个任务主要是工具的使用，参考工具的帮助文档，可以获取到更多的信息

#### 2023-01-10: 为apache服务添加指定的回复头部(Add Response Headers in Apache)
目标： 1. 在apache的response中，添加指定的header 信息 2.修改端口，3.修改默认的首页内容
```shell
# 这个任务也主要是修改配置，其中端口修改之前处理过，默认首页修改文件 `/var/www/html/index.html`
# 打开配置文件
vi /etc/httpd/conf/httpd.conf 
# 添加任务中指定的头部
Header set X-XSS-Protection "1; mode=block"
Header set append X-Frame-Options SAMEORIGIN
Header set X-Content-Type-Options nosniff

# 重启服务生效
systemctl restart httpd
```

#### 2023-01-11: Linux sudo 配置(Linux Configure sudo) rank: 543
目标：为指定用户添加sudo的执行权限
```shell
# 先查看指定的用户名是不是存在，不存在的话，需要先创建。保证存在用户才能执行添加管理员权限的逻辑
cat /etc/passwd|grep javed 

# 执行命令
visudo

# 可以参考其中的root 对配置，直接复制一行，然后修改用户名
javed    ALL=(ALL)   NOPASSWD:ALL
```
#### 2023-01-16: 安装和配置Tomcat 服务(Install and Configure Tomcat Server) rank: 477
目标： 安装tomcat服务器，开放指定端口，并且部署指定war包服务
```shell
# 首先肯定是安装服务，并建立系统服务
yum install tomcat -y
systemctl start tomcat && systemctl enable tomcat
# 如果需要，查看下服务状态
systemctl status tomcat

# 配置tomcat服务端口,修改Connector 标签里的端口 8080 -> 3004
vi /etc/tomcat/server.xml
# 重启tomcat服务
systemctl restart tomcat 

#修改文件权限,这里是看情况，不一定是root
chmod 777 ROOT.war

# 需要将指定的war 包拷贝到tomcat 配置的路径。会自动解压到对应的文件夹（ROOT）
mv ROOT.war /var/lib/tomcat/webapps/

```
#### 2023-01-19: 安装和配置pgsql的服务 （Install and Configure PostgreSQL） rank:338
目标：
- 安装pgsql
- 创建数据库 db8
- 创建用户 tim,并该用户赋予对db8的所有全新啊
- 使用md5校验密码  

这又是一个不太熟悉的操作，开发中多时候都是直接使用docker,然后权限的配置，就会使用GUI来操作,所以还是参考了别人的操作
```shell
# 先要安装pgsql，包括客户端和服务端
yum install postgresql-server postgresql-contrib -y
# 需要先对数据库做初始化后，才能正常启动，这一步会创建 /var/lib/pgsql 文件夹以及对应对默认配置
postgresql-setup initdb
# 安装完成后需要启动
systemctl start postgresql && systemctl enable postgresql && systemctl status postgresql
# pgsql 默认用户为 postgres,所以先切换过去
su - postgres
# 之后启动客户端命令，景区pgsql的命令行输入模式
pgsql
# 创建名称为kodekloud_8的数据库
create database kodekloud_8;
# 创建用户 kodekloud_gem,并指定密码
create user kodekloud_gem with ENCRYPTED PASSWORD 'YchZHRcLkL'; 
# 用户和数据库之间的权限处理，赋予所有权限
grant all privileges on database kodekloud_8 to "kodekloud_gem";
# 然后退出命令行，并且切回到root 
\q
exit
#尝试直接连接，会发现报错，因为我们密码是经过处理的
psql -U kodekloud_tim -d kodekloud_db8 -h 127.0.0.1 -W
# 所以编辑 /var/lib/pgsql/data/pg_hba.conf
# 在最后部分，修改 IPv4 和IPv6 下host 对应的加密反思为 md5,也就是最后一列的属性
# 重启pgsql的服务
systectl restart postgresql
```
个人感觉这里边的其实要了解的东西还是很多的，但我又并非是dba，所以一边就停留在有限但了解层面


#### 2023-01-20: 安装IPtables并进行配置 （IPtables Installation And Configuration）rank:290
目标：
- 安装iptables 防火墙应用
- 配置端口 3002 只允许负载均衡服务器访问
- 配置端口 3002 不允许外网访问
- 配置必须持久化，服务器重启后依然有效

iptables 是有一点点熟悉但，之前在学习linux基础知识时候有使用到，工作中也有用到
```shell
# 安装
yum install iptables-services  -y 
# 然后是启动三连
systemctl start iptables && systemctl enable iptables && systemctl status iptables

# 开始配置
# 这里有特别需要注意但地方，我是用 -I 的参数，也就是插入到 INPUT表的最前面
# iptables 的匹配规则是从上到下，一旦满足，就不在继续使用后边的规则，所以要注意添加的顺序问题
# INPUT、 DROP是表名称，大小写敏感
iptables -I INPUT -p tcp --dport 3003 -j DROP
iptables -I INPUT -p tcp --dport 3003 -s 172.16.238.14 -j ACCEPT

# 最后需要保持持久化
service iptables save 
```
总结：iptables 平时用的也不多，云服务器一般都在控制台那一层就处理了。另外，运维说，一般也不用iptables作为防火墙，会用fire-wall 这样的服务器，类似于ubuntu里的ufw吧，使用上可能是更加方便了。iptables的用去还是挺大的，在k8s的网络那一层，用的就挺多的。但.....这可是个大话题😳
