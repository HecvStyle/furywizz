---
author: furywizz
title: Linux信息收集常用命令
date: 2022-04-19T11:20:53+08:00
description: 收集Linux信息的常用命令
math: true
tags: ["Linux"]
ShowToc: true
ShowBreadCrumbs: false
---

**本文信息整理自[雨神博客](https://www.ddosi.org/linux-info/)，感谢大佬的分享。**

主要是平时开发工作中也经常会用到这些命令，但以前都没注意整理，这就是自己菜的原因吧。这次一锅端了，向牛逼的人学习，养成好的习惯。收集到自己这里，下次就不用到处去搜索了。

1. 查看操作系统类型、内核版本

```shell
## 操作系统类型
cat /etc/issue 

cat /etc/*-release 

cat /etc/lsb-release

cat /proc/version 

# 系统版本，内核等信息
uname -a 

uname -mrs 

rpm -q kernel 

dmesg | grep Linux 

ls /boot | grep vmlinuz-
```



2. 查看系统环境变量

```shell
cat /etc/profile 

cat /etc/bashrc 

cat ~/.bash_profile 

cat ~/.bashrc 

cat ~/.bash_logout 

env 

set
```

3. 查看系统运行的服务

```shell
## 运行的服务
ps aux 

ps -ef 

top 

cat /etc/services

## 指定用户的服务，这里是 root，服务漏洞，也可能存在由普通用户提权到 root
ps aux | grep root 

ps -ef | grep root
```

4. 查看系统安装的应用

```shell
# 这些个命令，除了dpkg，其他的平时好像没怎么用到，不太熟
ls -alh /usr/bin/ 

ls -alh /sbin/ 

dpkg -l 

rpm -qa 

ls -alh /var/cache/apt/archivesO 

ls -alh /var/cache/yum/
```

5. 常见的配置文件地址

```sh
cat /etc/syslog.conf 

cat /etc/chttp.conf 

cat /etc/lighttpd.conf 

cat /etc/cups/cupsd.conf 

cat /etc/inetd.conf 

cat /etc/apache2/apache2.conf 

cat /etc/my.conf 

cat /etc/httpd/conf/httpd.conf

cat /opt/lampp/etc/httpd.conf

##查看 /etc/ 目录下所有 root 用户的文件
ls -aRl /etc/ | awk '$1 ~ /^.r./'
```

6. 查看定时任务

```shell
crontab -l 

ls -alh /var/spool/cron 

ls -al /etc/ | grep cron 

ls -al /etc/cron* 

cat /etc/cron* 

cat /etc/at.allow 

cat /etc/at.deny 

cat /etc/cron.allow 

cat /etc/cron.deny 

cat /etc/crontab

cat /var/spool/cron/crontabs/root
```

7. 查找文件中的关键字

```shell
grep -i user [filename] 

grep -i pass [filename] 

grep -C 5 "password" [filename] 

find . -name "*.php" -print0 | xargs -0 grep -i -n "var $password" # Joomla
```

8. 网卡信息，连接的网络信息

```shell
/sbin/ifconfig -a 

cat /etc/network/interfaces 

cat /etc/sysconfig/network
```

9. 关于网络的配置信息，dns服务器、dhcp 服务器，防火墙配置等

```shell
cat /etc/resolv.conf 

cat /etc/sysconfig/network 

cat /etc/networks 

iptables -L 

hostname 

dnsdomainname
```

10. 查看当前有连接的主机和用户

```shell
lsof -i 

lsof -i :80 

grep 80 /etc/services 

netstat -antup 

netstat -antpx 

netstat -tulpn 

chkconfig --list 

chkconfig --list | grep 3:on 

last 

w
```

11. 系统网络缓存,这个平时开发几乎没用到

```shell
arp -e 

route 

/sbin/route -nee
```

12. 流量抓包

```shell
# tcpdump tcp dst [ip] [port] and tcp dst [ip] [port]
tcpdump tcp dst 192.168.1.7 80 and tcp dst 10.5.5.252 21
```

13. 用户相关信息

```shell

id 

who 

w 

last 

cat /etc/passwd | cut -d: -f1 

grep -v -E "^#" /etc/passwd | awk -F: '$3 == 0 { print $1}' 

cat /etc/sudoers 

sudo -l

#用户的文件路径
cat /etc/passwd 

cat /etc/group 

cat /etc/shadow 

ls -alh /var/mail/
```

14. 常见服务默认配置文件

```shell
cat /var/apache2/config.inc 

cat /var/lib/mysql/mysql/user.MYD 

cat /root/anaconda-ks.cfg
```

15. 比较通用的命令

```shell
# 查看本机的外网IP地址
curl ifconfig.me
curl ident.me
```

16. 常用的git操作

```yaml
#撤销最近一次的提交
git reset --soft HEAD^
# 修改提交的信息
git commit --amend
```



#### 总结

命令主要是摘抄自[雨神博客](https://www.ddosi.org/linux-info/)，这里经常使用的命里，基本都涉及到了，往后有其他命令，也会补充。

