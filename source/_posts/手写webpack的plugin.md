---
title: 手写webpack的plugin
tags:
  - 'webpack'
categories:
  - '前端'
  - '构建打包'
  - 'webpack'
date: 2017-05-08 10:12:42
---
经过上一篇博客分析webpack从命令行到打包完成的整体流程，我们知道了webpage的plugin是基于事件机制工作的，这样最大的好处是易于扩展。社区里很多webpack的plugin，但是具体到我们的项目并不一定适用，这篇博客告诉你如何入手写一个plugin，然后分析源码相关部分告诉你你的plugin是如何工作。知其然且知其所以然。
该系列博客的所有测试代码。
<!--more-->
从黑盒角度学习写一个plugin

所谓黑盒，就是先不管webpack的plugin如何运作，只去看官网介绍。

#### Compiler和Compilation两个类

官网介绍告诉我们，plugin涉及到源码中的Compiler类和Compilation类，并对这两个类进行了简要介绍。

Compiler在开始打包时就进行实例化，实例对象里面装着与打包相关的环境和参数，包括options、plugins和loaders等。
Compilation在每次文件变化重新打包时都进行一次实例化，它继承自Compiler，其实例对象里装着和modules及chunks相关的信息。
如果黑盒角度写plugin，知道这些就行了，没必要非去看源码。这两个对象上挂载的具体内容可以自己打印看看，不赘述。

#### 写一个简单的plugin

写plugin大致分为两个步骤：

>* 定义plugin
>* 在webpack.config.js中引用这个plugin
##### 定义plugin
```
function HTMLPlugin(options){
  // options是配置文件，你可以在这里进行一些与options相关的工作
}

// 每个plugin都必须定义一个apply方法，webpack会自动调用这个方法
HTMLPlugin.prototype.apply = function(compiler){
    // apply方法中会传入Compiler的实例compiler
    // 'emit'是该插件监听的事件，插件工作的逻辑在回调函数中
    compiler.plugin('emit', function(compilation, callback){
        // 回掉函数有两个参数
        // compilation和下一个回调函数，callback可以不传
        // 同步事件不传callback
        compilation.chunks.forEach(function(chunk){
            console.log('chunk.name', chunk.name);
            console.log('=====================================');
            //console.log('chunk.modules', chunk.modules.length);

            chunk.modules.forEach(function(module){
                console.log('module', module.resource);
                module.fileDependencies.forEach(function(filepath){
                    //console.log('filepath', filepath);
                });
            });

            chunk.files.forEach(function(filename){
                let source = compilation.assets[filename].source();
                //console.log('file', source);
            })
        });
        // 最后调用callback
        callback();
    });
}

module.exports = HTMLPlugin;
```

所有可以监听的事件请查看。
这里最让人疑惑的是compilation上的modules、chunks、assets，简单解释：

`compilation.modules`，每一个资源文件都会被编译成一个模块， 每个模块module.fileDependencies记录了模块依赖的其它模块
compilation.chunks，是entry的每个配置项及调用require.ensure的模块，每个chunk的， chunk.modules为chunk包含的模块以及模块所依赖的模块， chunk.files为每个配置项最后的输出结果文件，这里的值可以从compilation.assets获得
`compilation.assets`，整个打包流程最终要输出的文件
这里需要注意，compilation.chunks不仅包括webpack.config.js 中 entry 中配置的模块，还包括模块中使用require.ensure的模块。因为webpack在实现的时候也模仿commonjs规范想实现一个异步加载模块的功能，当使用require.ensure去加载模块时，只有在需要的时候才去下载模块，这可以实现类似懒加载的功能，避免一个页面打包后太大。

例如：
```
// webpack.config.js
entry: {
         index : './index.js',
         detail: './detail.js'
     }

// detail.js
require('./src/bundle_require.js'); //bundle_require.js没有依赖

// index.js
// testTapable.js 和 temp.js都没有依赖
require('./src/tapable/testTapable.js');
let Temp = require.ensure('./src/plugins/temp.js', function(){
    console.log('temp is loaded');
}, 'temp');
let temp = new Temp();
console.log('temp is resolved');
```
使用上面插件打包的结果：
这里写图片描述

##### 在webpack.config.js中引用这个plugin
```
var HTMLPlugin = require('./src/plugins/HTMLPlugin');

  module.exports = {
     //插件项
      plugins:[
          new HTMLPlugin()
      ],
      ...
  }
```
命令行执行webpack就可以打印出上图的结果。

##### 白盒角度看plugin如何工作

从源码分析apply方法到底如何调用，plugin方法到底如何定义一个插件等问题。

##### plugin的apply方法到底如何调用

bin/webapck.js
```
var webpack = require("../lib/webpack.js");
compiler = webpack(options);
```
没什么好解释，去看lib/webpack.js。

lib/webpack.js
```
const Compiler = require("./Compiler");
compiler = new Compiler();
if(options.plugins && Array.isArray(options.plugins)) {
    compiler.apply.apply(compiler, options.plugins);
}
```
显然compiler有一个apply方法，这里给其传入的参数是插件数组options.plugins。compiler中的apply方法实际是从Tapable中继承来的，所以移步Tapable，可以npm install一下来查看其源码。

Tapable
```
Tapable.prototype.apply = function apply() {
    for(var i = 0; i < arguments.length; i++) {
        arguments[i].apply(this);
    }
};
```
这个方法就是保证执行环境this的情况下依次执行传入参数中的方法，这些方法就是plugin。

plugin方法到底如何定义一个插件

很明显，这个方法在compiler上是有的，其实plugin方法是通过继承Tapable得到的。
```
Tapable.prototype.plugin = function plugin(name, fn) {
    if(Array.isArray(name)) {
        name.forEach(function(name) {
            this.plugin(name, fn);
        }, this);
        return;
    }
    if(!this._plugins[name]) this._plugins[name] = [fn];
    else this._plugins[name].push(fn);
};
```
这就是观察者模式中的注册观测者。

可用于监听的事件

可以在官方文档中查看，当然也可以仔细研读Compiler和Comilation两类去理解。例如：
```
Compiler.prototype.compile = function(callback) {
    var self = this;
    var params = self.newCompilationParams();
    self.applyPluginsAsync("before-compile", params, function(err) {
        if(err) return callback(err);

        self.applyPlugins("compile", params);

        var compilation = self.newCompilation(params);

        self.applyPluginsParallel("make", compilation, function(err) {
            if(err) return callback(err);

            compilation.finish();

            compilation.seal(function(err) {
                if(err) return callback(err);

                self.applyPluginsAsync("after-compile", compilation, function(err) {
                    if(err) return callback(err);

                    return callback(null, compilation);
                });
            });
        });
    });
};
```
compile方法是开始打包的一个重要方法，该方法会首先触发before-compile事件，也就是打包前需要干的事情，由一系列插件完成，然后触发compile事件，然后触发make事件，开始构建依赖关系。

##### 总结

我们了解了webpack的几个重要类及基本事件流程，通过这篇博客查看官网关于如何写plugin的介绍我们从黑盒角度知道了写plugin的基本步骤，对应webpack的工作流程
就可以轻松从白盒角度总结出plugin的工作原理。
