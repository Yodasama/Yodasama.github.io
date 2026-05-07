+++
date = '2026-05-07T14:41:30+08:00'
draft = false
title = 'Blog Setup'
tags = ['Hugo','Blog']
summary = '记录 Hugo + GitHub Pages 博客的内容管理、预览和发布流程。'
+++

## 如何管理hugo + Github Pages的内容

记录 Hugo + GitHub Pages 博客的内容管理、预览和发布流程。

<!--more-->

```text
/Yodasama-blog
├── content/          # 博客内容
├── static/              # 图片、头像、附件等静态资源
├── hugo.toml       # 网站配置
└── .github/workflows/hugo.yml  # 自动部署
```

### 新的文章

```shell
cd /../blog
hugo new posts/new.md
```

### 本地预览

```shell
hugo server -e production
```

### 发布到github pages

```shell
git add . 
git commit -m ""
git push
```

随后等Github Actions自动部署
