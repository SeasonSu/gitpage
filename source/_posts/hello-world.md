---
title: Hello World
type: "tags"
categories:
    - '部署'
    - '博客系统搭建'
tags: [hexo]
---

## 环境准备
需要git,Node.js环境

安装hexo
利用 npm 命令即可安装。（在任意位置点击鼠标右键，选择Git bash）

```
npm install -g hexo
```
创建hexo文件夹
选择存放hexo文件的位置,执行以下指令(Git bash终端下)，Hexo即会自动在目标文件夹建立网站所需要的所有文件。

<!--more-->
```
hexo init
```
安装依赖包
```
npm install
```
本地查看
现在我们已经搭建起本地的hexo博客了，执行以下命令(在hexo文件下)，然后到浏览器输入localhost:4000看看。

```
hexo generate #此命令是生成静态页面，不执行该命令也可以
hexo server
```
到此，本地服务以及搭建好了。

打包上传到github
如果没有github账户，则需要注册

创建仓库，配置ssh秘钥

注意：Repository name命名规则：你的github账号.github.io (这个一定要这么命名，具体我也不清楚)

hexo使用
目录结构
```
├── .deploy #需要部署的文件
├── node_modules #Hexo插件
├── public #生成的静态网页文件
├── scaffolds #模板
├── source #博客正文和其他源文件，404、favicon、CNAME
├── _drafts #草稿
├── _posts #文章,可以用子文件来存放文章
├── themes #主题
├── _config.yml #全局配置文件
└── package.json
```

配置文件的冒号“:”后面有一个空格
repo: 刚刚github创库地址.git
hexo命令行使用
```
hexo help #查看帮助
hexo init #初始化一个目录
hexo new "postName" #新建文章
hexo new page "pageName" #新建页面
hexo generate #生成网页，可以在 public 目录查看整个网站的文件
hexo server #本地预览，'Ctrl+C'关闭
hexo deploy #部署.deploy目录
hexo clean #清除缓存，**强烈建议每次执行命令前先清理缓存，每次部署前先删除 .deploy 文件夹**
```
简写

```
hexo n == hexo new
hexo g == hexo generate
hexo s == hexo server
hexo d == hexo deploy
```
编辑文章
新建文章
```
hexo new "标题"
```
在 _posts 目录下会生成文件 标题.md
```
title: Hello World
date: 2015-07-30 07:56:29 #发表日期，一般不改动
categories: hexo #文章文类
tags: [hexo,github] #文章标签，多于一项时用这种格式
---
正文，使用Markdown语法书写
编辑完后保存，hexo server 预览
hexo部署

执行下列指令即可完成部署。
```
```
hexo generate
hexo deploy
hexo deploy问题：Deployer not found: git
```


```
npm install hexo-deployer-git --save
```
重新deploy即可

图片
我这里是使用本地的图片

安装

```
npm install hexo-asset-image --save
```
安装该插件后，每次hexo new 新建博文后，会在该文件同级目录下生成一个和文件同名的文件夹，该文件夹就是用来存放图片的
确保你的_config.yml 配置 post_asset_folder: true
然后使用
```
![logo](logo.jpg)
```
在博文中插入logo.jpg.

来源：
http://wuxiaolong.me/2015/07/31/build-blog-by-hexo/
http://www.tuicool.com/articles/umEBVfI
