---
title: gogs 自动化部署
date: 2017-04-07 17:38:13
tags: ["服务器","自动化部署"]
categories: ["部署","gogs自动化部署"]
from: '原'
---

#### 1.创建仓库
 服务器上需要配置两个 git 仓库，一个用于代码版本管理的远程仓库，一个用于用户访问的本地仓库。这里的「远程仓库」并不等同于托管代码的「中央仓库」，这两个仓库都是为了自动同步代码并部署网站而存在。
<!--more-->
在存放远程仓库的目录中（假设是 /home/ourai/repos）执行 git init --bare bridge.git 会创建一个包含 git 各种配置文件的「裸仓库」。

切换到存放用户所访问文件的目录（假设为 /home/ourai/www，如果不存在则在 /home/ourai 中执行mkdir www）：
```
git init
git remote add origin /root/gogs-repositories/seateam/wxoauth.git
git fetch
git checkout master
```

#### 2.配置 Git Hook

将目录切换至 xx.git/hooks，用
`cp post-receive.sample post-receive` 拷贝并

`cd /root/gogs-repositories/seateam/xx.git/hooks`

用vim post-receive 修改。其内容大致如下：
```
#!/bin/sh

unset GIT_DIR

NowPath=`pwd`
DeployPath="/alidata/www/wxoauth"

cd $DeployPath
git pull origin master

cd $NowPath
exit 0
```
使用 `chmod +x post-receive` 改变一下权限后，服务器端的配置就基本完成了。
#### 3.上线与测试分开
```
while read oldrev newrev refname
do
    if [[ $refname =~ .*/deploy$ ]];
    then
        #!/bin/sh
        unset GIT_DIR
	NowPath='pwd'
	DeployPath="/alidata/deploy/wxci"
	cd $DeployPath
	git pull origin deploy
	cd $NowPath
	exit 0
    else
        #!/bin/sh
        unset GIT_DIR
	NowPath='pwd'
	DeployPath="/alidata/www/wxci"
	cd $DeployPath
	git pull origin master
	cd $NowPath
	exit 0
    fi
done
```
#### 4.挂起进程

`cd /alidata/gogs`  
`nohup ./gogs web &`    守护进程
git hook 钩子，监听操作自动下载资源＝自动部署
