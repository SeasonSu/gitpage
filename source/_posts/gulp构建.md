---
title: gulp构建
tags:
  - '构建打包'
  - 'gulp'
categories:
  - '前端'
  - '构建打包'
  - 'gulp'
date: 2017-04-20 11:09:08
from: '原'
---

#### 入门指南

##### 1. 全局安装 gulp：
```
    $ npm install --global gulp
```
##### 2. 作为项目的开发依赖（devDependencies）安装：
```
    $ npm install --save-dev gulp
```
##### 3. 在项目根目录下创建一个名为 gulpfile.js 的文件：
```
    var gulp = require('gulp');

    gulp.task('default', function() {
      // 将你的默认的任务代码放在这
    });
```
##### 4. 运行 gulp：
```
    $ gulp
```
<!--more-->

```
var gulp        = require('gulp');
var browserSync = require('browser-sync');
// 引入组件
var jshint = require('gulp-jshint');
var sass = require('gulp-sass');// 编译Sass
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var connect = require('gulp-connect'); //自动刷新服务
var rev  = require('gulp-rev');//加MD5后缀
var revReplace = require('gulp-rev-replace');//替换引用的加了md5后缀的文件名，修改过，用来加cdn前缀
var minifyHtml = require('gulp-minify-html'); //压缩html
var minifyCss = require('gulp-minify-css');
var gulpif = require('gulp-if');
var  cssver = require('gulp-make-css-url-version'); //css url
var imagemin = require('gulp-imagemin');
var pngquant = require('imagemin-pngquant'); //png图片压缩插件
var spritesmith = require('gulp-spritesmith');
var spriter=require('gulp-css-spriter');
var condition = true;
var paths = {
    scripts: './app/js/*.js',//js存放
    scss:'./app/css/scss/*.scss',//scss存放
    css:'./app/css/*.css',//看守的css目录
    cssScss:'./app/css',//压缩sass存放的css目录
    minCss:'./app/css/minCss',//压缩的minicss
    rootJs:'./dist/js', //打包后js
    rootCss:'./dist/css',//打包后css
    minHtml:'./dist',//打包后html
};
// 检查脚本
gulp.task('lint', function() {
    return gulp.src(paths.scripts)
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});
// 编译Sass
gulp.task('sass', function() {
    gulp.src(paths.scss)
        .pipe(sass())
        .pipe(gulp.dest(paths.cssScss));
});
// 合并，压缩文件
gulp.task('scripts', function() {
    gulp.src(paths.scripts)
        .pipe(concat('app.js'))
        .pipe(gulp.dest(paths.rootJs))
        .pipe(rename('app.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest(paths.rootJs));
});
//浏览器监听刷新
gulp.task('reload',function(){
    gulp.src('./*.html').pipe(connect.reload());
});
//服务器自动刷新
gulp.task('connect',function(){
    connect.server({
        port:3000,
        livereload:true
    })
})
//压缩Html/更新引入文件版本
gulp.task('miniHtml', function () {
  return gulp.src('./*.html')
    //.pipe(revCollector())
    .pipe(gulpif(
      condition, minifyHtml({
        empty: true,
        spare: true,
        quotes: true
      })
    ))
    .pipe(gulp.dest(paths.minHtml));
});
//压缩/合并CSS
gulp.task('miniCss', function () {
    gulp.src(paths.css)
        .pipe(minifyCss({
            advanced: false,//类型：Boolean 默认：true [是否开启高级优化（合并选择器等）]
            compatibility: 'ie7',//保留ie7及以下兼容写法 类型：String 默认：''or'*' [启用兼容模式； 'ie7'：IE7兼容模式，'ie8'：IE8兼容模式，'*'：IE9+兼容模式]
            keepBreaks: true,//类型：Boolean 默认：false [是否保留换行]
            keepSpecialComments: '*'
            //保留所有特殊前缀 当你用autoprefixer生成的浏览器前缀，如果不加这个参数，有可能将会删除你的部分前缀
        }))
        .pipe(cssver())
        .pipe(gulp.dest(paths.minCss));
});
gulp.task('minImage', function () {
    return gulp.src('./app/images/*')
        .pipe(imagemin({
            progressive: true,
            use: [pngquant()] //使用pngquant来压缩png图片
        }))
        .pipe(gulp.dest('./dist/images'));
});
gulp.task('sprite',function(){
    var timestamp =+ new Date();
    //需要自动合并雪碧图的样式文件
    return gulp.src('./app/css/*.css')
    .pipe(spriter({
        //生成的spriter的位置
        'spriteSheet':'./dist/images/sprite/sprite'+timestamp+'.png',
        //生成样式文件图片引用地址的路径
        //如下将生产：backgound:url(../images/sprite20324232.png)
        'pathToSpriteSheetFromCSS':'../images/sprite'+timestamp+'.png'
    }))
    .pipe(minifyCss())
    //产出路径
    .pipe(gulp.dest('./dist/css/sprite'));
});
//监听文件状态
gulp.task('watch', function() {
    gulp.watch("./*.html",['reload']);
});
gulp.task('default',['watch','scripts','sass','lint','connect','miniHtml','miniCss','minImage','sprite']);
```
