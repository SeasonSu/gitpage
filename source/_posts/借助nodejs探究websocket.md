---
title: 借助nodejs探究websocket
date: 2017-04-08 15:49:22
tags: ["node","websocket"]
categories: ["node","websocket"]
---
#### 文章导读：

>* 一、概述-what's WebSocket?
>* 二、运行在浏览器中的WebSocket客户端+使用ws模块搭建的简单服务器
>* 三、Node中的WebSocket
>* 四、socket.io
>* 五、扩展阅读
#### 一、概述-what's WebSocket?

##### 1.1 为什么我们需要WebSocket这样的实时的通信协议？

WebSocket是web通信方式的一种，像我们熟知的HTTP协议也是web通信方式的一种。但是我们知道HTTP协议是一种无状态的协议，其服务端本身不具备识别客户端的能力，必须借助外部的一些信息比如说session和cookie，才能与特定的客户端保持通信。
<!--more-->
也就是说我们所发送的每一个HTTP的请求都会带上请求头中一些相应的信息还有cookie，这明显会增加我们传输的信息的体量从而带来一定的网络延迟，对于一些对通信的实时性要求比较高的应用来说就是不可忍受的了，比如说聊天程序或者是运行在浏览器中的实时小游戏。最郁闷的却还是这些头信息和cookie往往对于服务器响应客户端的请求来说是多余的，也就是说虽然我每个请求都带了这些信息，但是服务器与客户端的交互过程中可能根本用不上这些信息。

为了改善HTTP请求的这种网络延迟的情况，也出现了一些适应不同需求的其他的[web通信]方式，比如说：轮询，长轮询( long-polling )，数据流，EventSouce等等，WebSocket便是其中一种。

实际上大多数基于因特网（或者局域网）的网络链接通常都包含长连接和基于TCP套接字的双向消息交换。但是TCP协议是属于最底层的网络通信协议了，让一些不能信任的客户端脚本去访问底层的TCP套接字显然是不太安全的，因此WebSocket实现了一种较为安全的方案，它允许客户端脚本在客户端和支持WebSocket协议的服务器之间创建双向的套接字连接。从而使实时通信的某些网络操作变得简单。

##### 1.2 WebSocket是如何工作的？

我们知道了WebSocket的主要作用是，允许服务器端与客户端进行全双工（full-duplex）的实时通信。这里有个例子特别好：HTTP协议像发电子邮件，发出后必须等待对方回信；WebSocket则是像打电话，服务器端和客户端可以同时向对方发送数据，它们之间存着一条持续打开的数据通道。

我们先看一下一个基于WebSocket协议通信的请求头和响应头(下面简单实例中的一个消息头)：



其中与WebSocket协议相关的信息：

>* 1 Upgrade:websocket-------HTTP1.1协议规定，Upgrade头信息表示将通信协议从HTTP/1.1转向该项所指定的协议；
>* 2 Connection:Upgrade------表示浏览器通知服务器，如果允许，就将通信协议升级到websocket协议；
>* 3 Origin------------------用于验证浏览器域名是否在服务器许可的范围内;
>* 4 Sec-WebSocket-Key-------则是用于握手协议的密钥，是base64编码的16字节随机字符串;
>* 5 Sec-WebSocket-Accept----是服务器在浏览器提供的Sec-WebSocket-Key字符串后面，添加“258EAFA5-E914-47DA-95CA-C5AB0DC85B11” 字符串，然后再取sha-1的hash值。浏览器将对这个值进行验证，以证明确实是目标服务器回应了webSocket请求；
>* 6.Sec-WebSocket-Location--一般情况下还有这个响应消息头用来表示进行通信的WebSocket网址，这里面可能是因为我例子中设置了127.0.0.1，所以这个信息省略掉了。
客户端通过一个WebSocket握手的过程建立一个WebSocket连接。整个过程看起来是这个样子的：



完成握手以后，WebSocket协议就在TCP协议之上，客户端和服务器端就可以开始传送数据了。

websocket协议用ws表示，加密的websocket协议用wss协议，就像普通的HTTP协议用http表示，加密的HTTP协议用https表示一样。

下面我们就通过一些实例看一下websocket的不同实现是如何应用的。

#### 二、 运行在浏览器中的WebSocket客户端+使用ws模块搭建的简单服务器

我们可以通过跑起来这个简单的实例看一下如何编写运行在浏览器中的WebSocket客户端，并且看它是怎样与服务器端交互的。

##### 2.1 运行实例

我们把客户端代码和服务端代码准备好，然后启动服务器监听端口，比如说8080，再然后运行我们的客户端代码即可看到效果。

我们的客户端代码写在html文件中：


```
1 var onOpen = function() {
2            console.log("Socket opened.");
3                 socket.send("Hi, Server!");
4             },
5             onClose = function() {
6                 console.log("Socket closed.");
7             },
8
9
10             onMessage = function(data) {
11                 console.log("We get signal:");
12                 console.log(data);
13             },
14
15
16             onError = function() {
17                 console.log("We got an error.");
18             },
19
20             
21             socket = new WebSocket("ws://127.0.0.1:8080/");
22
23         socket.onopen = onOpen;
24         socket.onclose = onClose;
25         socket.onerror = onError;
26         socket.onmessage = onMessage;
```
我们通过它建立连接并且监听open和messege等事件，与此同时，我们想要得到服务器的响应。服务器端的js代码：


```
1 var WebSocketServer = require('ws').Server;
 2 var wss = new WebSocketServer({ port: 8080 });
 3
 4 wss.on('connection', function connection(ws) {
 5   ws.on('message', function incoming(message) {
 6     console.log('received: %s', message);
 7   });
 8
 9   ws.send('something');
10 });
```
这个简单的websocket服务器使用了[ ws模块 ]，如果没有安装过，要先安装一下：

1 `sudo npm install ws`
然后在我们的命令行执行：

1 `node simpleWSserver.js`
我们的服务器启动之后，我们运行客户端代码可以看到：

浏览器：



命令行：



整个过程看起来是这个样子的：

![](http://img2.tuicool.com/I7nmuqr.png!web)

2.2 运行在浏览器中的websocket客户端

我们在浏览器中的websocket主要做的事情无非是以下几个：

1 建立连接和关闭连接
2 发送数据和接收数据
3 处理错误
对应的会触发以下的事件：

1`onopen`
2`onmessage`
3`onclose`
4`onerror`
2.2.1 建立连接和关闭连接

通常我们新建了一个WebSocket的实例就可以建立一个连接：
```
1 if(window.WebSocket != undefined) {
2     var socket = new WebSocket("ws://127.0.0.1:8080/");
3 }
```
建立连接之后的WebSocket实例有一个readyState属性，用来标识当前的状态：

0-正在连接
1-连接成功
2-正在关闭
3-关闭成功
连接成功后会触发onopen事件，这时我们就可以向服务器发送数据了：
```
1 var onOpen = function() {
2       console.log("Socket opened.");
3       socket.send("Hi, Server!");
4  }
5 socket.onopen = onOpen;
```
要是关闭连接的话就会出发onclose事件：
```
1 var onClose = function() {
2         console.log("Socket closed.");
3   }
4 socket.onclose = onClose;
```
2.2.2 发送数据和接收数据

在连接建立成功后触发的onopen事件中我们通过send()方法发送数据给服务器：

`1 socket.send("Hi, Server!");`
除了发送字符串类型的数据，也可以使用 Blob 或 ArrayBuffer 对象发送二进制数据。不仅如此，我们还可以发送JSON数据：
```
1  var onOpen = function() {
 2       var msg = {
 3          type: "message",
 4          text: "something",
 5          id:   "number",
 6          date: Date.now()
 7       };
 8
 9    // Send the msg object as a JSON-formatted string.
10    socket.send(JSON.stringify(msg));
11   }
12  socket.onopen = onOpen;
```
这时会触发服务器端的message事件：
```
1 ws.on('message', function incoming(message) {
2     console.log('received: %s', message);
3   });
```
同时，服务器端发来信息的时候：

`1 ws.send('something');`
也会触发客户端的onmessage事件：
```
1 var onMessage = function(data) {
2         console.log("We get signal:");
3         console.log(data);
4   }
5 socket.onmessage = onMessage;
```
2.2.3 处理错误

发生的错误会触发onerror事件：
```
1 var onError = function() {
2      console.log("We got an error.");
3  }
4 socket.onerror = onError;
```
三、Node中的WebSocket

WebSocket在Node中的实现[ WebSocket-Node ]使我们可以在Nodejs中使用websokcet开发客户端和服务器端实时交互的应用程序。我们可以运行客户端和服务器实时交换随机数的例子看看它是怎么工作的：
node socketserver.js

node socketclient.js



#### 四、socket.io

现在很流行的websocket的实现socket.io同样包括客户端和服务器端两部分。它不仅简化了接口，使得操作更容易，而且对于那些不支持WebSocket的浏览器，会自动降为Ajax连接，最大限度地保证了兼容性。它的目标是统一通信机制，使得所有浏览器和移动设备都可以进行实时通信。

##### 4.1 socket.io与WebSocket的区别在哪里呢？

websocket是浏览器对象，websocket api是浏览器提供给我们的用于浏览器和服务器实时通信的接口。

websocket在node中的实现使我们可以开发服务端程序时使用websocket的特性。

在我们使用websocket的时候，因为他是浏览器提供的接口，所以会涉及到一些兼容性和支持性的问题。如果我们对程序所运行的环境或局限不是那么了解的化，那么可能会出现问题：

[ Differences between socket.io and websocket ] 。而socket.io则是进化了的websocket api。socket.io建立在websocket之上，它在合适的时候使用websocket。

4.2 socket.io实现聊天室

使用websocket或socket.io可以从一个简单的聊天室程序开始。对于socket.io来说，这非常容易。

基于 node ，这里使用express和socket.io：

`1 npm install --save express@4.10.2`
`2 npm install --save socket.io`
那么我们就可以开始写聊天程序了。它需要的就是一个客户端的聊天窗口和一个用来接收消息和分发消息的服务器。

我们需要三个文件，分别新建：package.json,index.js,index.html.

package.json:

```

1 {
2   "name": "chat-application",
3   "version": "0.0.1",
4   "description": "my first socket.io app",
5   "dependencies": {
6     "socket.io": "^1.3.5"
7   }
8 }
```

index.js:


```
1 var app = require('express')();
 2 var http = require('http').Server(app);
 3 var io = require('socket.io')(http);
 4
 5 app.get('/', function(req, res){
 6   res.sendfile('index.html');
 7 });
 8
 9 io.on('connection', function(socket){
10   console.log('a user connected');
11   //监听客户端的消息
12   socket.on('chat message', function(msg){
13       //用于将消息发送给每个人，包括发送者
14     io.emit('chat message', msg);
15   });
16   socket.on('disconnect', function(){
17     console.log('user disconnected');
18   });
19 });
20
21 http.listen(3000, function(){
22   console.log('listening on *:3000');
23 });
```
index.html:


```
1 <!doctype html>
 2 <html>
 3   <head>
 4     <title>Socket.IO chat</title>
 5     <style>
 6       * { margin: 0; padding: 0; box-sizing: border-box; }
 7       body { font: 13px Helvetica, Arial; }
 8       form { background: #000; padding: 3px; position: fixed; bottom: 0; width: 100%; }
 9       form input { border: 0; padding: 10px; width: 90%; margin-right: .5%; }
10       form button { width: 9%; background: rgb(130, 224, 255); border: none; padding: 10px; }
11       #messages { list-style-type: none; margin: 0; padding: 0; }
12       #messages li { padding: 5px 10px; }
13       #messages li:nth-child(odd) { background: #eee; }
14     </style>
15   </head>
16   <body>
17     <ul id="messages"></ul>
18     <form action="">
19       <input id="m" autocomplete="off" /><button>Send</button>
20     </form>
21     <script src="https://cdn.socket.io/socket.io-1.2.0.js"></script>
22     <script src="http://code.jquery.com/jquery-1.11.1.js"></script>
23     <script>
24       var socket = io();
25       $('form').submit(function(){
26         //io.emit提供给我们可以发送给所有人的事件io.emit('some event', { for: 'everyone' });
27         socket.emit('chat message', $('#m').val());
28         $('#m').val('');
29         return false;
30       });
31       socket.on('chat message', function(msg){
32         $('#messages').append($('<li>').text(msg));
33       });
34     </script>
35   </body>
36 </html>
```
先运行：

node index.js
在打开两个http://localhost:3000的窗口就可以开始聊天了：


socket.io官网上有很详细的使用方法和教程：[ socket.io doc ]

五、扩展阅读

[ 浏览器对象-WebSocket ]

[web通信]

[细说WebSocket]

[ WebSocket MDN ]

[ WebSocket-Node implementation ]

[ A Guide For WebSocket ]

[ socket.IO ]

[ writing websocket client ]

[ deferences between socket.io and websocket ]

[ websocket and socketio ]

[ socket.io application ]
