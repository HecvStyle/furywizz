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
