+++
date = '2026-05-08T11:06:13+08:00'
draft = false
title = '网络安全面经'
summary = '记录网安常用的面试题'
tags = ['security','面经']
toc = true

+++

## OWASP TOP 10

#### Injection/注入

**Q：什么是SQL注入**

A：应用程序将用户输入的数据，直接拼接到 SQL 语句中执行，攻击者可以构造恶意 SQL 语句，从而绕过认证、获取数据库数据、修改数据，甚至控制服务器。

**Q：原理是什么**

A：

```sql
### SQL代码
SELECT * FROM users 
WHERE username = 'admin' 
AND password = '123456'

### 拼接语句
sql = "SELECT * FROM users WHERE username='%s' AND password='%s'" % (user, pwd)

### 进行注入
admin ' OR '1' = '1

### 注入结果
sql = "SELECT * FROM users WHERE username='admin' OR '1' = '1'"

WHERE username = 'admin' OR '1' = '1'
AND password = ''

语句判断永远为真 所以执行成功
```

**Q：注入有哪些类型**

A：

#联合查询注入： `union select database(),user()`

​	核心条件：UNION 前后的 SELECT 字段数量必须一致

```sql
SELECT id, username FROM users WHERE id = 1
UNION SELECT 1, database();
```

主要看三件事：

1. **原查询有几列**
2. **哪些列会回显到页面**
3. **能不能用 UNION SELECT 拼接额外查询**

使用场景：商品详情页，用户信息页



#报错注入：updatexml() ；extractvalue()

有些数据库函数在报错时，会把查询结果带到错误信息里。攻击者就可以故意构造错误，让数据库把想查的数据“塞进报错内容”。

```sql
SELECT updatexml(1,concat('~',database(),'~'),1);
# 可能结果：XPATH syntax error: '~testdb~'
and extractvalue(1,concat(0x7e,(select database())))
```

主要看两件事：

1. **应用是否把数据库错误直接返回给前端**
2. **数据库错误信息中是否能包含查询结果**



#盲注：

​	时间盲注：`and if(substr(database(),1,1)='a',sleep(5),1)`

​	布尔盲注：`and substr(database(),1,1)='a'`

```sql
1）substr()函数
string substr(string,start,length)第一个参数为要处理的字符串 start为开始位置 length为获取到的长度
2）Left（）函数
Left ( string, n ) string为要获取的字符串 n为长度
3）ORD()函数
ord()函数同ASCII（），将字符转为ascii 此函数为返回第一个字符的ASCII码 经常与上面的函数进行组合使用
```



#堆叠注入：`1'; drop table users#` 部分数据库支持

#宽字节注入：某些编码一个汉字占两个字节，addslashes()被绕过

**Q：SQL注入如何绕过WAF**

A：

白盒：代码审计

黑盒：

架构层面，寻找源站点地址，适用于使用了云WAF，利用同网段或服务器进行注入

资源限制角度：发送大文件绕过

协议方面：比如只对get过滤或对某一种文件过来

规则层面的绕过：注释绕过，url编码绕过，特殊字符绕过，%0a绕过，空字节%00

**Q：单引号过滤怎么办**

A：转换成url编码 或者16进制 或者其他的编码方式

**Q：SQL写WebShell的方式**

A：select ... into outfile   或者 SQLmap --os --cmd 或者 --os-shell

secure_file_priv配置不当，函数功能（限制往指定目录写文件）

`secure_file_priv=/var/mysql-files/` 

**Q：SQL无回显的情况下如何得到数据**

A：时间盲注、DNSlog

攻击者准备DNSlog域名，诱导目标服务器发DNS请求，看解析结果，如果有解析结果 说明成功触发

**Q：基于Cookie怎么注入**

A：

**利用：**

1. 登录绕过
2. 数据泄露
3. 数据篡改

**防御：**

1. 参数化查询（预编译）
2. 正则表达式过滤
3. 开启魔术引号
4. 加装WAF等



#### XSS

**Q：什么是XSS？**

A：跨站脚本攻击。攻击者将恶意 JavaScript 注入网页，当其他用户访问页面时，脚本会在浏览器执行。

**Q：有哪些类型？**

A：

#反射型XSS：`http://test.com?q=<script>alert(1)</script>`

一般需要诱导用户点击，服务器直接返回



#存储型XSS：存入数据库，用户访问页面时自动执行；从评论区 留言版等存入



#DOM型XSS：`document.write(location.hash)`用户输入直接进入页面

`https://example.com/profile#<img src=x onerror=stealCookie()>`

```
攻击者传播“恶意 URL”
↓
受害者浏览器执行前端 JS
↓
前端 JS 把恶意内容插入 DOM
↓
浏览器执行恶意代码
```

利用：

 	1. 窃取cookie，`document.cookie / Javascipt`如果cookie没有设置HttpOnly，会被截取session和登录态
 	2. 会话劫持，直接接管用户账号，应用于管理员后台，OA系统等，评论区或其他地方插入 诱使管理权限的用户进行点击
 	3. 页面钓鱼，XSS动态修改页面DOM，例如
 	4. 例如：插入假的登录框；修改支付页面；模拟系统提示
 	5. 键盘记录，`keydown`
 	6. 内网探测，需要受害者在企业内网。`fetch("http://192.168.1.1")`
 	7. 恶意跳转，`location.href="恶意网站"`

防御：

1. 输出编码：将`<script>alert(1)</script>` 转义为`&lt;script&gt;alert(1)&lt;/script&gt;` 
2. 白名单过滤
3. 过滤JavaScript事件的标签
4. 开启Http-only



#### XXE（XML外部实体注入）

应用解析 XML 时，允许 XML 实体引用外部资源，攻击者借此读取文件、发起请求甚至攻击内网。

XML中有Entity，类似于变量

```xml
<!ENTITY name "hello">
<user>&name;</user>
<user>hello</user>
```

除了普通字符串，XML还能引用：文件、URL、网络资源

`<!ENTITY test SYSTEM "file:///etc/passwd">` 

利用：找到XML输入点(XML API;文件上传;Office 文档;SVG) -> 插入恶意实体 -> 引用实体 -> 服务器解析xml

1. 读取服务器文件
2. SSRF：`<!ENTITY xxe SYSTEM "http://127.0.0.1:8080">`
3. 无回显XXE：通过DNS HTTP带出数据

修复：

使用语言中推荐的禁用外部实体的方法

1. PHP：libxml_disable_entity_loader(true);
2. Java:
   1. DocumentBuilderFactory dbf =DocumentBuilderFactory.newInstance();
   2. dbf.setExpandEntityReferences(false);

3. Python:
   1. from lxml import etree
   2. xmlData = etree.parse(xmlSource,etree.XMLParser(resolve_entities=False))

手动黑名单过滤：过滤 XML 中的相关关键词，比如：<!DOCTYPE、<!ENTITY SYSTEM、PUBLIC 等。

#### CSRF

攻击者诱导用户访问恶意页面，利用用户已经登录的身份，向目标网站发送请求。

浏览器携带cookie，服务器没有验证请求是否合法

种类：

GET：主要利用图片、链接等标签的src属性来触发、POST：提交表单或请求、Jsonp：利用JSONP跨域特性进行攻击

修复：

1. CSRF Token：服务器给每个用户Token并绑定session，
2. SameSite Cookie：
   1. None：不限制
   2. Lax：部分跨站不带
   3. Strict：完全禁止跨站携带
3. Origin/Reference：请求来源不同，但是也可能不生效（隐私设置，浏览器不发送
4. 双重Cookie：浏览器能自动带Cookie但是不能读取内容，访问时再提交一下cookie，攻击者不知道
5. 二次验证 / 用户交互确认
6. JWT（JSON Web Token）：不会主动携带 可以防范CSRF



#### SSRF

服务器端请求伪造

攻击者可以借目标服务器的身份、网络位置、权限，去访问它能访问的资源。

很多服务需要根据用户提供的URL 主动发请求 `requests.get(user_url)`

服务器能访问一些攻击者访问不到的，如：内网、localhost、Docker

利用：

1. 内网探测：端口、后台、管理接口（Redis，Docker API），通过响应时间、返回内容判断哪些端口开放
2. 访问localhost：127.0.0.1
3. 读取云Metadata，如AWS：`http://169.254.169.254`。可获取临时云凭证，接管云资源
4. 协议利用：file:// ; ftp:// ; gopher://(构建原始TCP请求) 等
5. Redis / FastCGI攻击
6. 无回显SSRF（DNS回连、HTTP回连、时间差）

修复：

1. 不要让用户决定服务器访问哪里
2. 白名单机制
3. 禁止内网IP
4. 禁止危险协议，只允许http / https
5. DNS固定解析：防止请求时重新解析
6. 最小权限原则
7. 网络层隔离：Redis 不开放；Docker API 不开放；Metadata 限制



#### RCE

远程代码执行

利用：

1. 命令执行漏洞 `os.system("ping " + ip)` ，输入` 127.0.0.1; whoami` 。最终执行第二条
2. 常见危险函数

```php
system() # 调用系统shell执行命令
exec() # 不直接输出 保存在数组
  # 利用：exec($_GET['cmd']);  ?cmd=cat /etc/passwd
    
shell_exec() # 通过 Shell 执行命令，并将完整输出作为字符串返回
  # 利用：echo shell_exec($_GET['cmd']);  ?cmd=uname -a
  
passthru() # 执行外部程序，并将原始输出直接传递到浏览器/终端。
  				 # 通常用于二进制流或需要原样输出的场景。
```

```Python
os.system() # 调用系统shell执行命令
subprocess.Popen(shell=True) # 这是更底层、更强大的进程控制方式
```

```java
Runtime.getRuntime().exec() // 启动一个新的系统进程
```

3. 文件上传 -> WebShell
   1. ` <?php system($_GET['cmd']); ?>` 

4. 反序列化RCE：反序列化攻击者可控数据
   1. Java : ReadObject / ObjectOutPutStream
   2. PHP : unserialize
   3. Python : pickle.loads
5. 及时更新组件：Log4j，Struts2，Fastjson
6. 代码审计、输入验证、参数化查询、使用安全的API、限制文件权限



#### 文件操作

##### 文件上传

正常上传只存储文件。如果文件类型检验不严格，服务器解析配置错误，上传目录可执行

上传恶意脚本文件

利用：

1. 上传WebShell：`<?php system($_GET['cmd']); ?>` 
2. 前端校验绕过：抓包改需求
3. MIME类型绕过：服务器只检查Content-Type，攻击者改成image，实际上传php
4. 文件后缀绕过
   1. 大小写 .pHp
   2. 双后缀 shell.php.jpg
   3. 空格 shell.php%20
   4. Shell.php.
5. 解析漏洞利用：如shell.php.jpg。部分中间件可能按php执行
6. 图片马
7. 审查上传点的元素：如果在前端限制上传文件类型 直接增加类型

```shell
GIF89a
<?php ... ?>
如果服务器后续包含/解析文件 可能导致RCE
```

##### 文件下载

```shell
/download?file=xxx
../../etc/passwd
任意文件读取，属于路径穿越
```

修复手段：

1. 白名单校验
2. 服务端校验，不能只靠前端JS
3. 校验真实文件内容，不能只看后缀 、 MIME
4. 随机文件名
5. 限制文件大小
6. 隔离存储 对象存储（OSS）
7. 最小权限原则
8. WAF

#### 越权漏洞

##### 水平越权

同权限级别的用户，能够访问或操作其他用户的数据。

- 系统只验证了“是否登录”
- 没验证“这个资源是不是你的”

利用方式：

1. 修改ID参数：`GET /api/user/1/profile` -> `GET /api/user/2/profile`
2. 修改Cookie / JWT的用户标识
3. 越权修改数据

```json
POST /api/edit
{
  "user_id":2,
  "nickname":"hack"
}
```

4. 下载接口越权：`/download?file=report_1002.pdf`

防范：

1. 服务端做资源归属校验

```Python
order = Order.get(id=order_id)

# 正确
order = Order.get(
    id=order_id,
    user_id=current_user.id
)
```

2. 不信任前端传输的user_id

```Python
user_id = request.json["user_id"]

# 正确
user_id = session.user.id
```

3. 接口统一鉴权中间件：ACL（Access Control List）RBAC（Role-Based Access Control）

##### 垂直越权

低权限用户获取高权限用户能力

利用：

1. 直接访问管理员接口

```html
例：/admin/deleteUser
前端进行了隐藏按钮，但是后端没有校验权限
```

2. 修改角色字段

```json
{"role":"admin"}
```

```http
POST /updateProfile
{
  "is_admin":1
}
```

3. 篡改JWT（json web token)

```json
{"role":"user"} --> {"role":"admin"}
```

4. 功能隐藏 ≠ 权限控制

防范：

1. 后端强制RBAC权限控制

```Python
if current_user.role != "admin":
    return 403
```

2. JWT正确校验
   1. 验证签名
   2. 校验exp
   3. 禁止alg = none
3. 敏感操作二次验证

#### 未授权访问

系统没有进行身份认证或权限校验，导致任何人都能直接访问敏感资源

利用：

1. 管理后台未授权：`http://example.com/admin`
2. API未授权：`GET /api/users` 返回username , password
3. 数据库未授权：Redis（6379）、MongoDB
4. 文件目录未授权：目录遍历
5. Swagger / Actuator 未授权：暴露接口文档、环境变量、数据库配置

Redis：

1. redis以root身份运行，config set。内容为SSH公钥内容 文件路径满足公钥存放的位置 就可以给root账户写入SSH公钥文件，通过ssh登录目标服务器
2. 同上，知道了网站路径后，config set，内容为一句话木马。
3. 不知道网站绝对路径时，利用linux的定时任务：Linux会监测/etc/crontab的内容，将反弹shell的命令使用redis备份到/etc/crontab

修复：

1. 禁止外部访问Redis服务端口
2. 禁止使用root权限启动redis
3. 配置安全组，限制可连接Redis服务器的IP

#### 目录遍历

用户输入的文件路径未做安全校验

```Python
filename = request.GET["file"]
open("/var/www/uploads/" + filename)

# 用户上传
../../etc/passwd
#最终
open("/var/www/uploads/../../etc/passwd")
--> open("/etc/passwd")
```

利用：

1. 文件读取
2. 读取配置文件
   1. config.php / .env
   2. application.yml / application.properties
   3. settings.py
3. 配合文件包含漏洞
4. 碰到过滤 怎么绕过
   1. URL 编码绕过
   2. 多写绕过：`replace("../","")` 写入 `....//`

防范：

1. 不允许用户控制路径，如`open("/upload/" + filename)`
2. 白名单，访问指定文件
3. 路径规范化
4. 禁止访问敏感目录


#### 弱口令

使用过于简单、容易猜测或常见的密码，导致攻击者能够通过爆破、字典攻击等方式登录系统。

利用：

1. 字典攻击
2. 暴力破解
3. 社工

修复：

1. 设置复杂密码策略
2. 限制登录次数
3. MFA多因素认证
4. 强制修改默认密码
5. IP限制

## 信息收集

### 子域名泛解析

**原因：**将没有明确设置的子域名一律解析到一个IP地址，造成都能访问的假象

ping一个不存在的域名 发现能解析时，说明使用了泛解析

**解决方法：**

IP黑名单：随机访问不存在的域名，通过返回结果分析是否存在泛解析。如果确定存在，使用脚本工具 OneForAll

HTTP Host：DNS能解析，但是`Host:random.example.com` 返回404 说明不是真实业务



