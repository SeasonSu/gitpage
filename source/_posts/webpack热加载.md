---
title: 用webpack做vue热加载
tags:
  - 'webpack'
categories:
  - '前端'
  - '构建打包'
  - 'webpack'
date: 2017-04-15 12:03:09
from: '原'
---

#### 介绍
使用 webpack 有一段时间了，其中的模块热加载加快了开发的速度。它无需刷新，只要修改了文件，客户端就立刻做热加载
<!--more-->
`webpack.config.js`

```
const webpack = require('webpack')
const glob = require('glob')
const fs = require('fs')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const colors = require('colors')
const path = require('path')
const TransferWebpackPlugin = require('transfer-webpack-plugin')
const express = require('express')
const WebpackDevMiddleware = require('webpack-dev-middleware')
const WebpackHotMiddleware = require('webpack-hot-middleware')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const argv = require('minimist')(process.argv.slice(2))
const bs = require('browser-sync').create();
let bsFlag = false
const gulp = require('gulp')
/**
 * 编译配置
 * @type {Object}
 */
const setting = {
    src:'./src', // 源文件目录
    release:'./dist' // 编译后文件
}

/**
 * 获取配置
 * @return {[type]} [description]
 */
const getConf = function(){

    let config = {
        entry:{

        },
        output: {
            path:path.resolve(__dirname, 'dist'),
            publicPath: '/',
            filename: '[name]-[hash].js',
            chunkFilename:"[id].chunk.js"
        },
        module: {
            loaders: [
                {
                        test: /\.vue$/,
                        exclude: /node_modules/,
                        loader: 'vue'
                    },
                    {
                        test: /\.html$/,
                        loader: 'html'
                    },
                    {
                        test: /\.(js|jsx)$/,
                        loader: 'babel',
                        query: {
                            presets: [
                                require.resolve('babel-preset-react'),
                                require.resolve('babel-preset-es2015')
                            ]
                        },
                        include: path.resolve(process.cwd(), './'),
                        exclude: /node_modules/
                    },
                    {
                        test: /\.(png|jpg|gif|svg|mp3|wav|ogg|json)$/,
                        loaders: [
                            'url?limit=1024&hash=sha512&digest=hex&name=[name]-[hash].[ext]'
                        ]
                    }
            ]
        },
        resolve: {
            extensions: ['', '.js', '.json', '.scss','.hbs','.html'],
            alias: {
                'vue': 'vue/dist/vue.js'
            }
        },
        plugins:[
        //    new MyPlugin({options: ''}),
        new webpack.HotModuleReplacementPlugin(),
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.NoErrorsPlugin()

        ],
    }

    config.entry = entries()
    // 处理html
    config.plugins = config.plugins.concat(htmlPlugins())

    // 处理版本控制
    if(checkEnvPro()){
        config.plugins.push(
            new webpack.DefinePlugin({
                'process.env': {
                    NODE_ENV: '"production"'
                }
            }),
            new webpack.optimize.UglifyJsPlugin({
                compress: {
                    warnings: false
                }
            })
        )
    }else{
    //    config.devtool = '#source-map'
    }

    return config
}

/**
 * 获取入口文件
 * @return {[type]} [description]
 */
const entries = function(){

    let targetJs = path.resolve(setting.src, 'entries')

    console.log(colors.red(targetJs))

    let entryFiles = glob.sync(targetJs + '/*.{js,jsx}')

    let map = {}

    let targetFiles = glob.sync(setting.release + '/*.{js,css,html}')

    entryFiles.forEach(function (entry) {

        let fileName = entry.substring(entry.lastIndexOf('\/') + 1, entry.lastIndexOf('.'))

        map[fileName] = path.resolve(__dirname,entry)
        /**
         * 清理上个版本文件
         * @type {[type]}
         */
        targetFiles.forEach(function(file){

            let sourceName = file.substring(file.lastIndexOf('\/') + 1, file.lastIndexOf('-'))

        	let htmlName = file.substring(file.lastIndexOf('\/') + 1, file.lastIndexOf('.'))

            if(sourceName == fileName || htmlName == fileName){

                !argv.hot && fs.existsSync(file) && fs.unlinkSync(file)

            }
        })
    })

    return map
}

/**
 * 处理html-views
 * @return {[type]} [description]
 */
const htmlPlugins = function () {

    let entryHtml = glob.sync(setting.src + '/views/*.html')

    let plugins = []

    entryHtml.forEach(function(entry){

        let filePath = path.join(__dirname, entry)

        let fileName = filePath.substring(filePath.lastIndexOf('\/') + 1, filePath.lastIndexOf('.'));

        plugins.push(new HtmlWebpackPlugin({
    		chunks: [fileName],
        	cache:false,
            filename: fileName + '.html',
            inject:true,
            hash:true,
            template:filePath,
            minify:checkEnvPro() ? { removeAttributeQuotes: true } : false,
        	// templateContent: function(templateParams, compilation){
        	// 	let contentStr = fs.readFileSync(filePath).toString()
        	// 	return contentStr
        	// }
        }))
    })

    return plugins
}

/**
 * 检查版本，增加版本功能控制
 * @return {[type]} [description]
 */
const checkEnvPro = function(){
    if (process.env.NODE_ENV === 'production') {
        return true
    } else {
        return false
    }
}

/**
 * 监听html
 * @return {[type]} [description]
 */
const browserSync = function(){
    if(bsFlag){
        return
    }
     bsFlag = true
    bs.init({
        server: {
            baseDir: setting.release
        },
        files: ['./src/**'],
        port: 8090,
        files: [
            {
                match: ['./src/**'],
                fn: function (event, file) {
                    if (event === 'change') {
                        webpack(getConf(),function(){
                            bs.reload();
                        })
                    }
                }
            }
        ]
    });
}


function MyPlugin(options) {}

MyPlugin.prototype.apply = function(compiler) {

  compiler.plugin('compilation', function(compilation) {
    //  console.log(colors.red('compilation'))
    //  browserSync()
  });

};



module.exports = getConf()

```


`webpack.js`
```
const webpack = require('webpack')
const webpackDevServer = require('webpack-dev-server')
const webpackDevMiddleware = require('webpack-dev-middleware')
const webpackHotMiddleware = require('webpack-hot-middleware')
const colors = require('colors')
const bs = require('browser-sync').create();
const express = require('express')
const app = express()
const opn = require('opn')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const connectHistoryApiFallBack = require('connect-history-api-fallback')
const path = require('path')
const config = require(path.join(__dirname, 'webpack.config'))
const port = process.env.PORT || 8090
/**
 * 设置confg，hot参数
 */
const setConfig = function(){
    var extras = ['./dev-client'];
//    var extras = ['webpack-hot-middleware/client?path=/__webpack_hmr&reload=true']
    Object.keys(config.entry).forEach(function(name) {
        config.entry[name] = extras.concat(config.entry[name])
    })
    config.plugins.push(
        new webpack.HotModuleReplacementPlugin(),
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.NoErrorsPlugin()
    )
    return config
}

var compiler = webpack(setConfig())
var proxyMiddleware = require('http-proxy-middleware')
var devMiddleware = require('webpack-dev-middleware')(compiler, {
    publicPath: config.output.publicPath,
    stats: {
        colors: true,
        chunks: false
    },
})

var hotMiddleware = require('webpack-hot-middleware')(compiler)
compiler.plugin('compilation', function(compilation) {
    compilation.plugin('html-webpack-plugin-after-emit', function(data, cb) {
        hotMiddleware.publish({
            action: 'reload'
        })
        cb()
    })
})
app.use(devMiddleware)
app.use(hotMiddleware)
app.use(express.static(config.output.path))

app.use(require('connect-history-api-fallback')())


app.listen(port, function(err) {
    if (err) {
        console.log(err)
        return
    }
    console.log(colors.green('服务已开启，端口:'+port))
//    opn('http://localhost:'+port)
})

```


`package.json`

```
{
  "name": "back",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "dev": "webpack-dev-server --inline --hot",
    "build": "export NODE_ENV=production && webpack --progress --hide-modules",
    "hot": "node webpack.js --hot"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "autoprefixer": "^6.7.7",
    "babel-core": "^6.2.1",
    "babel-loader": "^6.2.0",
    "babel-plugin-transform-runtime": "^6.1.18",
    "babel-preset-es2015": "^6.1.18",
    "babel-preset-react": "^6.23.0",
    "babel-preset-stage-0": "^6.1.18",
    "babel-runtime": "^6.2.0",
    "browser-sync": "^2.18.8",
    "connect-history-api-fallback": "^1.3.0",
    "css-loader": "^0.23.1",
    "express": "^4.15.2",
    "extract-text-webpack-plugin": "^2.1.0",
    "file-loader": "^0.8.5",
    "fs": "0.0.1-security",
    "glob": "^7.1.1",
    "gulp": "^3.9.1",
    "html-loader": "^0.4.5",
    "html-webpack-plugin": "^2.28.0",
    "http-proxy-middleware": "^0.17.4",
    "jade": "^1.11.0",
    "minimist": "^1.2.0",
    "node-sass": "^3.4.2",
    "opn": "^4.0.2",
    "postcss-loader": "^1.3.3",
    "sass-loader": "^3.2.3",
    "style-loader": "^0.13.0",
    "stylus-loader": "^1.4.2",
    "template-html-loader": "0.0.3",
    "transfer-webpack-plugin": "^0.1.4",
    "vue": "^2.1.0",
    "vue-loader": "^10.0.0",
    "vue-resource": "^1.0.3",
    "vue-router": "^2.1.1",
    "vue-scroll": "^2.0.1",
    "vue-style-loader": "^1.0.0",
    "vue-template-compiler": "^2.1.0",
    "vuex": "^2.1.1",
    "webpack": "^1.13.1",
    "webpack-dev-middleware": "^1.8.3",
    "webpack-hot-middleware": "^2.12.2"
  }
}

```
