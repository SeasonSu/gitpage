---
title: canvas代码块
tags:
  - '前端'
categories:
  - '前端'
  - '知识点'
date: 2017-06-26 14:32:53
---

### 在画布中获取特定颜色的像素数量
下面的函数将返回画布上颜色（RGB格式）为r、g、b的像素数量。如果用户希望像这篇博客文章中在另一个区域绘画，那么这将非常有用。
```
function getpixelamount(canvas, r, g, b) {
  var cx = canvas.getContext('2d');
  var pixels = cx.getImageData(0, 0, canvas.width, canvas.height);
  var all = pixels.data.length;
  var amount = 0;
  for (i = 0; i < all; i += 4) {
    if (pixels.data[i] === r &&
        pixels.data[i + 1] === g &&
        pixels.data[i + 2] === b) {
      amount++;
    }
  }
  return amount;
};
```

<!--more-->
### 在画布中获取某一个像素的颜色
下面的代码片段返回一个对象，该对象在画布的x和y的位置上具有RGBA值。这可以用来确定鼠标光标是否在一个特定的形状中。
```
function getpixelcolour(canvas, x, y) {
  var cx = canvas.getContext('2d');
  var pixel = cx.getImageData(x, y, 1, 1);
  return {
    r: pixel.data[0],
    g: pixel.data[1],
    b: pixel.data[2],
    a: pixel.data[3]
  };
}
```
### 链接方法
这个类提供的jQuery风格的链接访问2D背景的方法和属性。
```
function Canvas2DContext(canvas) {
  if (typeof canvas === 'string') {
    canvas = document.getElementById(canvas);
  }
  if (!(this instanceof Canvas2DContext)) {
    return new Canvas2DContext(canvas);
  }
  this.context = this.ctx = canvas.getContext('2d');
  if (!Canvas2DContext.prototype.arc) {
    Canvas2DContext.setup.call(this, this.ctx);
  }
}
Canvas2DContext.setup = function() {
  var methods = ['arc', 'arcTo', 'beginPath', 'bezierCurveTo', 'clearRect', 'clip',
    'closePath', 'drawImage', 'fill', 'fillRect', 'fillText', 'lineTo', 'moveTo',
    'quadraticCurveTo', 'rect', 'restore', 'rotate', 'save', 'scale', 'setTransform',
    'stroke', 'strokeRect', 'strokeText', 'transform', 'translate'];

  var getterMethods = ['createPattern', 'drawFocusRing', 'isPointInPath', 'measureText', // drawFocusRing not currently supported
    // The following might instead be wrapped to be able to chain their child objects
    'createImageData', 'createLinearGradient',
    'createRadialGradient', 'getImageData', 'putImageData'
  ];

  var props = ['canvas', 'fillStyle', 'font', 'globalAlpha', 'globalCompositeOperation',
    'lineCap', 'lineJoin', 'lineWidth', 'miterLimit', 'shadowOffsetX', 'shadowOffsetY',
    'shadowBlur', 'shadowColor', 'strokeStyle', 'textAlign', 'textBaseline'];

  for (let m of methods) {
    let method = m;
    Canvas2DContext.prototype[method] = function() {
      this.ctx[method].apply(this.ctx, arguments);
      return this;
    };
  }

  for (let m of getterMethods) {
    let method = m;
    Canvas2DContext.prototype[method] = function() {
      return this.ctx[method].apply(this.ctx, arguments);
    };
  }

  for (let p of props) {
    let prop = p;
    Canvas2DContext.prototype[prop] = function(value) {
      if (value === undefined)
        return this.ctx[prop];
      this.ctx[prop] = value;
      return this;
    };
  }
};

var canvas = document.getElementById('canvas');

// Use context to get access to underlying context
var ctx = Canvas2DContext(canvas)
  .strokeStyle('rgb(30, 110, 210)')
  .transform(10, 3, 4, 5, 1, 0)
  .strokeRect(2, 10, 15, 20)
  .context;

// Use property name as a function (but without arguments) to get the value
var strokeStyle = Canvas2DContext(canvas)
  .strokeStyle('rgb(50, 110, 210)')
  .strokeStyle();
```
代码只有特权代码的可使用
这些片段是从特权代码仅是有用的，例如扩展或特权的应用程序。

### 保存画布图像文件
下面的函数接受一个画布对象和目标文件路径串。画布被转换成PNG文件并保存到指定的位置。该函数返回时，该文件已被完全保存它解决的承诺。
```
function saveCanvas(canvas, path, type, options) {
    return Task.spawn(function *() {
        var reader = new FileReader;
        var blob = yield new Promise(accept => canvas.toBlob(accept, type, options));
        reader.readAsArrayBuffer(blob);

        yield new Promise(accept => { reader.onloadend = accept });

        return yield OS.File.writeAtomic(path, new Uint8Array(reader.result),
                                         { tmpPath: path + '.tmp' });
    });
}
```
### 将一个远程页面加载到画布元素上
下面的类首先创建隐藏的iframe元件并附加一个监听到所述框架的加载事件。一旦远程页面加载时，remotePageLoaded方法火灾。这种方法获取到iframe的窗口的引用，并提请该窗口的画布对象。

需要注意的是，如果你正在运行的Chrome页面这仅适用。如果您尝试运行代码作为普通的网页，你会得到一个“安全错误‘代码’1000' 的错误。
```
RemoteCanvas = function() {
    this.url = 'http://developer.mozilla.org';
};

RemoteCanvas.CANVAS_WIDTH = 300;
RemoteCanvas.CANVAS_HEIGHT = 300;

RemoteCanvas.prototype.load = function() {
    var windowWidth = window.innerWidth - 25;
    var iframe;
    iframe = document.createElement('iframe');
    iframe.id = 'test-iframe';
    iframe.height = '10px';
    iframe.width = windowWidth + 'px';
    iframe.style.visibility = 'hidden';
    iframe.src = this.url;
    // Here is where the magic happens... add a listener to the
    // frame's onload event
    iframe.addEventListener('load', this.remotePageLoaded, true);
    //append to the end of the page
    window.document.body.appendChild(iframe);
    return;    
};

RemoteCanvas.prototype.remotePageLoaded = function() {
    // Look back up the iframe by id
    var ldrFrame = document.getElementById('test-iframe');
    // Get a reference to the window object you need for the canvas
    // drawWindow method
    var remoteWindow = ldrFrame.contentWindow;

    //Draw canvas
    var canvas = document.createElement('canvas');
    canvas.style.width = RemoteCanvas.CANVAS_WIDTH + 'px';
    canvas.style.height = RemoteCanvas.CANVAS_HEIGHT + 'px';
    canvas.width = RemoteCanvas.CANVAS_WIDTH;
    canvas.height = RemoteCanvas.CANVAS_HEIGHT;
    var windowWidth = window.innerWidth - 25;
    var windowHeight = window.innerHeight;

    var ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0,
                  RemoteCanvas.CANVAS_WIDTH,
                  RemoteCanvas.CANVAS_HEIGHT);
    ctx.save();
    ctx.scale(RemoteCanvas.CANVAS_WIDTH / windowWidth,
              RemoteCanvas.CANVAS_HEIGHT / windowHeight);
    ctx.drawWindow(remoteWindow,
                   0, 0,
                   windowWidth, windowHeight,
                   'rgb(255, 255, 255)');
    ctx.restore();
};
```
用法：
```
var remoteCanvas = new RemoteCanvas();
remoteCanvas.load();
```
### 将图像文件转换为base64字符串
下面的代码获取远程图像，并转换其内容Data URI scheme。
```
var canvas = document.createElement('canvas');
var ctxt = canvas.getContext('2d');
function loadImageFile(url, callback) {
  var image = new Image();
  image.src = url;
  return new Promise((accept, reject) => {
    image.onload = accept;
    image.onerror = reject;
  }).then(accept => {
    canvas.width = this.width;
    canvas.height = this.height;
    ctxt.clearRect(0, 0, this.width, this.height);
    ctxt.drawImage(this, 0, 0);
    accept(canvas.toDataURL());
  });
}
```
用法：
```
loadImageFile('myimage.jpg').then(string64 => { alert(string64); });
```
