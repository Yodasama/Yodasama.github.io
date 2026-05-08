+++
date = '2026-05-08T11:06:13+08:00'
draft = false
title = '网络安全面经'
summary = '记录网安常用的面试题'
tags = ['security','面经']
toc = true

+++

### OWASP TOP 10

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

联合查询注入： `union select database(),user()`

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



报错注入：updatexml() ；extractvalue()

有些数据库函数在报错时，会把查询结果带到错误信息里。攻击者就可以故意构造错误，让数据库把想查的数据“塞进报错内容”。

```sql
SELECT updatexml(1,concat('~',database(),'~'),1);
可能结果：XPATH syntax error: '~testdb~'
```

主要看两件事：

1. **应用是否把数据库错误直接返回给前端**
2. **数据库错误信息中是否能包含查询结果**



盲注：

​	时间盲注：`and if(substr(database(),1,1)='a',sleep(5),1)`

​	布尔盲注：`and substr(database(),1,1)='a'`

堆叠注入：`1'; drop table users#` 部分数据库支持



利用：

防御：



#### XSS

**Q：什么是XSS？**

A：跨站脚本攻击。攻击者将恶意 JavaScript 注入网页，当其他用户访问页面时，脚本会在浏览器执行。

**Q：有哪些类型？**

A：

反射型XSS：`http://test.com?q=<script>alert(1)</script>`

一般需要诱导用户点击，服务器直接返回



存储型XSS：存入数据库，用户访问页面时自动执行；从评论区 留言版等存入



DOM型XSS：`document.write(location.hash)`用户输入直接进入页面

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

