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



报错注入：updatexml() ；extractvalue()

```sql

```

