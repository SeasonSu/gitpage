---
title: koa2搭建接口服务器实践
tags:
  - 'koa2'
categories:
  - 'node'
  - 'koa2'
date: 2017-04-15 01:38:08
from: '原'
---
#### 准备工作
 安装新版node，es7需要高版本node支持， 并且需要babel转换es7语法
 async/await是异步流程控制更好的解决方案
    `.babelrc`
```
   {
		"presets": ["es2015-node5"],
		"plugins": [
			"transform-async-to-generator",
			"syntax-async-functions"
		]
	}
```
<!--more-->

`入口index`
```
require('babel-register');
require('./server/index.js')
```

#### 目录结构

----------
* doc `数据库文件，项目文档`
    - .doc
    - .sql
* backEnd `后台文件`
    - Semantic UI `（样式框架）`
    - vue／angular `（mvc框架）`
* frontEnd `前端文件 vue/ng/react`
    - app `原文件`
    - release `编译文件`
    - bower.json `引用`
* server `服务端文件`
    - config `配置模块（数据库配置，环境配置）`
        - index.js
    - controller `控制器，统一入口模块`
    - routers `路由文件`
        - (user) `接口处理模块`
        - index.js `入口文件`
    - codes `code编码模块`
        - code.js
        - index.js
    - models `数据库模型模块Sequelize`
    - services `业务模块，处理封装数据库models`
    - upload  `文件上传目录`
    - utils `工具类`
    - views `node模版引擎`
        - handlebars
    - logs `日志模块`

#### todo

`中间件  session redis 缓存处理

### package.json
```
{
  "name": "server",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "babel-plugin-syntax-async-functions": "^6.13.0",
    "babel-plugin-transform-async-to-generator": "^6.24.1",
    "babel-preset-es2015-node5": "^1.2.0",
    "babel-register": "^6.24.1",
    "colors": "^1.1.2",
    "fs": "0.0.1-security",
    "koa": "^2.0.0-alpha.8",
    "koa-body": "^2.0.0",
    "koa-logger": "^2.0.1",
    "koa-router": "^7.1.1",
    "koa-views": "^6.0.2",
    "mysql": "^2.13.0",
    "node.extend": "^1.1.6",
    "path": "^0.12.7",
    "sequelize": "^3.30.4"
  }
}

```

####  services模块入口
```
const fs = require('fs')
const path = require('path')
const Sequelize = require('sequelize')
const env = process.env.NODE_ENV || 'development'
const config = require('../config/index')[env]
const utils = require('../utils/index')
const sequelize = new Sequelize(config.database, config.username, config.password, config);

const dbStorage = []
const modelRoot = process.cwd() + '/models'
const models = utils.getFiles(modelRoot)

models.map(function(file){
    let model = sequelize.import(path.join(modelRoot,file))
    dbStorage[model.name] = model
})

module.exports = dbStorage

```

#### 控制器
```
/*============================================================================
 * 控制器入口
 ============================================================================*/
const Koa = require('koa');
const router = require('../routers/index')
const app = new Koa();
const http = require('http')
const views = require('koa-views')
const colors = require('colors')
// const cors = require('koa-cors')
const config = require('../config')
const logger = require('koa-logger')
// 引入模版views
// app.use(views(__dirname + '/views', { extension: 'jade' }))
app.use(views( __dirname + '/views', {
    extension: 'hbs',
    map: { hbs: 'handlebars' }
}));
// 引入路由
app.use(router.routes())
	.use(router.allowedMethods());
// 跨域
// app.use(cors())
// 日志
app.use(logger())
// 开启服务
let server = http.createServer(app.callback());
server.listen(config.base.port);
console.log(colors.red('服务已开启：端口'+ config.base.port))

```

#### 路由入口文件
```
/*============================================================================
 * 接口路由入口
 ============================================================================*/
const colors = require('colors')
const fs = require('fs')
const path = require('path')
const Router = require('koa-router')
const router = new Router()
const utils = require('../utils')

/**
 * 遍历路由文件夹，注册路由
 * @type {String}
 */
let routesArray = utils.getFiles(__dirname)

routesArray.map(function(item){
    let fileName = './' + item
    if(fs.existsSync(path.resolve(__dirname, fileName))){
        let routesInstance = require(fileName)
        router.use(routesInstance.routes())
        	.use(routesInstance.allowedMethods());
    }else{
        console.log('路由 ----' + path.resolve(__dirname, fileName) + '  not found')
    }
})

module.exports = router

```


#### 某路由文件
```
const Router = require('koa-router')
const router = new Router()
const body = require('koa-body')()
const colors = require('colors')
const modules = require(process.cwd() + '/services/index')
const codes = require(process.cwd() + '/codes/index')
const utils = require(process.cwd() + '/utils/index')

/**
 * 检查用户存在
 * @param  {[type]} userName [description]
 * @return {[type]}          [description]
 */
const checkUserExit = async (username) => {
    if(!username){
        return
    }
    return new Promise((resolve, reject) => {
        modules.users.findAll({
            where: {
                username: username,
            }
        }).then((result)=>{
            if(result && result.length > 0){
                resolve(true)
            }else{
                resolve(false)
            }
        })
    })
}

router.post('/login',body, async (ctx) => {
    ctx.set('Access-Control-Allow-Method', 'POST');
    ctx.set('Access-Control-Allow-Origin', '*')
    let username = ctx.request.body.username
    let password = ctx.request.body.password
    if(!username || !password){
        ctx.body = codes.set('2')
        return
    }
    // 是否存在用户
    let isExit = await checkUserExit(username)
    let data = {isExit:isExit}

    ctx.body = utils.extend(codes.set('0'),data)

})




router.get('/getUser/:id', async (ctx,next) => {

  let  id = ctx.params.id;

  await modules.users.findAll({
        where: {
            id: id,
        }
    }).then((result)=>{
        let params = JSON.stringify(result)
        ctx.body = JSON.stringify(result)
  })

});


module.exports = router

```

#### utils

```
const fs = require('fs')
const path = require('path')
const colors = require('colors')
const utils = require('./utils')

utils.prototype.getFiles = function(root){
    let fileArray = []
    const getDeepFiles = function(fileRoot,parentRoot){
        fs.readdirSync(fileRoot)
        .forEach(function (file) {
            if(file == 'index.js'){
                return
            }
            let curPath = fileRoot + '/' + file
            if(fs.statSync(curPath).isDirectory()){
                getDeepFiles(curPath,file)
            }else{
                if(parentRoot){
                    fileArray.push(parentRoot + '/' + file)
                }else{
                    fileArray.push(file)
                }
            }
        })
    }
    getDeepFiles(root)
    return fileArray
}

```

以上是部分文件显示，如果需要详细框架搭建，留言或QQ联系博主我
