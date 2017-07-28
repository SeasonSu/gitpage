---
title: nodejs模版引擎
date: 2017-04-08 15:45:37
tags: "node"
categories: ["node","node模版引擎"]
from: '原'
---

#### 1.ejs  （写法有点类jsp／php)

Node 开源模板的选择很多，但推荐像我这样的老人去用 EJS，有 Classic ASP/PHP/JSP 的经验用起 EJS 来的确可以很自然，也就是说，你能够在 <%...%> 块中安排 JavaScript 代码，利用最传统的方式 <%=输出变量%>（另外 <%-输出变量是不会对 & 等符号进行转义的）
<!--more-->
```
<% if (names.length) { %>  
  <ul>  
    <% names.forEach(function(name){ %>  
      <li foo='<%= name + "'" %>'><%= name %></li>  
    <% }) %>  
  </ul>  
<% } %>  
```
#### 2. jade

jade全新的
Jade有两点是超出传统模板技术的。
##### 第一、简洁。
注意，简洁并非单指更少的符号，而是看是否能match你的需要。Jade强制的缩进格式能凸显html的结构，而对于前端来说，最重要的任务恰恰是处理结构，而不像一般的html author那样是处理内容。反过来说，假如你的主要任务是处理内容，比如写作blog之类的，那你应该用wiki或者markdown之类的，而不应该用Jade。
##### 第二、html-aware
传统模板技术其实是通用模板，即模板引擎并不care你输出的是html还是其他格式的文本。而Jade专为HTML设计，因此可以做许多传统模板做不到的专门针对html的优化。举个几个简单的例子：
>* 1. 决定如何输出属性（当属性赋值为null/false时不输出属性，为true时只需属性不需要值，这在传统模板里写起来很麻烦、代码难看易出错）
>* 2. 自动产生well-formed结构（甚至可决定是否要输出结束标签，而传统模板理论上也做不到这点，除非引入额外的html parse或tidy）
>* 3. 换行处理，避免产生额外的空白节点
>* 4. 对输出的变量自动进行特殊字符的encode
```
!!!
html
    head
        title #{title}
        meta(charset="UTF-8")
    body
        div.description #{description}
        ul
            - each data in datas
                li.item(id='item_'+data.index)
                    span= data.time
                    a.art(href=data.url)= data.title

```
#### 3.handlebars
```
<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{title}} - Page Test</title>
</head>
<body>
    <div class="description">{{description}}</div>
    <ul>
{{#datas}}
        <li class="item" id="item_{{index}}"><span>{{time}}</span><a href="{{url}}" class="art">{{title}}</a></li>
{{/datas}}
    </ul>
</body>
</html>
```

#### 总结：
Jade 很简洁，表达能力也很强，但不够直观，学习和适应成本不低。
Jade 处理模板时计算量大，在没有缓存的情况下性能低是肯定的。
Jade 对于一个不擅长前端、喜欢Bootstrap和Ctrl c + v 实在不能提高开发效， 性能瓶颈
          Ejs 适用于写JSP/PHP后台的人使用，上手快
          Handlebars 更接近前端的模版引擎，使用方便顺手
