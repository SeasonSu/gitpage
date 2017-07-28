---
title: 前端mvc框架backbone.js
tags:
  - '框架'
  - 'backbone'
categories:
  - '前端'
  - '框架'
  - 'backbone'
date: 2017-04-17 09:51:48
---

#### 简介
Web 应用程序越来越关注于前端，使用客户端脚本与 Ajax 进行交互。由于 JavaScript 应用程序越来越复杂，如果没有合适的工具和模式，那么 JavaScript 代码的高效编写、非重复性和可维护性方面会面临挑战。`模型-视图-控制器 (MVC) 是一个常见模式，可用于服务器端开发以生成有组织以及易维护的代码。`MVC 支持将数据（比如通常用于 Ajax 交互的 JavaScript Object Notation (JSON) 对象）从表示层或从页面的文档对象模型 (document object model, DOM) 中分离出来，也可适用于客户端开发。
<!--more-->
`Backbone（也称为 Backbone.js）`是由 Jeremy Ashkenas 创建的一个轻量级库，可用于创建 MVC 类应用程序。Backbone：
强制依赖于 Underscore.js，`Underscore.js` 是一个实用型库
非强制依赖于 jQuery/Zepto
根据模型的变更自动更新应用程序的 HTML，有助于代码维护
促进客户端模板使用，避免了在 JavaScript 中嵌入 HTML 代码
模型、视图、集合和路由器是 Backbone 框架中的主要组件。在 Backbone 中，模型会存储通过 RESTful JSON 接口从服务器检索到的数据。模型与视图密切关联，负责为特定 UI 组件渲染 HTML 并处理元素上触发的事件，这也是视图本身的一部分。
常用缩略词
`DOM：文档对象模型
MVC：模型-视图-控制器
SPI：单页界面`


#### SPI 应用程序：Backbone.Router 和 Backbone.history
含有大量 Ajax 交互的应用程序越来越像那些无页面刷新的应用程序。这些应用程序常常试图限制与单个页面的交互。该 SPI 方法提高了效率和速度，并使整个应用程序变得更灵敏。状态概念代替了页面概念。散列 (Hash) 片段被用于识别一个特定状态。散列片段 是 URL 中散列标签 (#) 后的那部分，是该类应用程序的关键元素。清单 1 显示了一个 SPI 应用程序使用两个不同的散列片段产生的两个不同状态。
#### 清单 1. SPI 或 Ajax 应用程序中的两个不同状态
http://www.example.com/#/state1
http://www.example.com/#/state2
Backbone 提供一个称为路由器（版本 0.5 前称之为控制器）的组件来路由客户端状态。路由器可以扩展 Backbone.Router 函数，且包含一个散列映射（routes 属性）将状态与活动关联起来。当应用程序达到相关状态时，会触发一个特定活动。清单 2 展示了一个 Backbone 路由器示例。
#### 清单 2. Backbone.Router 示例：routers.js
```
App.Routers.Main = Backbone.Router.extend({

   // Hash maps for routes
   routes : {
      "" : "index",
      "/teams" : "getTeams",
      "/teams/:country" : "getTeamsCountry",
      "/teams/:country/:name : "getTeam"
      "*error" : "fourOfour"
   },

   index: function(){
       // Homepage
   },

   getTeams: function() {
       // List all teams
   },
   getTeamsCountry: function(country) {
       // Get list of teams for specific country
   },
   getTeam: function(country, name) {
       // Get the teams for a specific country and with a specific name
   },
   fourOfour: function(error) {
       // 404 page
   }
});
```
创建的每个状态可以为书签。当 URL 碰到类似下面情况时，会调用这 5 个活动（index、getTeams、getTeamsCountry、getTeamCountry 和 fourOfour）。
http://www.example.com 触发 index()
http://www.example.com/#/teams 触发 getTeams()
http://www.example.com/#/teams/country1 触发 getTeamsCountry() 传递 country1 作为参数
http://www.example.com/#/teams/country1/team1 触发 getTeamCountry() 传递 country1 和 team1 作为参数
http://www.example.com/#/something 触发 fourOfour() 以作 * （星号）使用。
要启动 Backbone，先实例化页面加载的路由器，并通过指令 Backbone.history.start() 方法监视散列片段中的任何变更，如 清单 3 所示。
#### 清单 3. 应用程序实例化（使用 jQuery）
```
$(function(){
    var router = new App.Routers.Main();
    Backbone.history.start({pushState : true});
})
```
当实例化路由器时，会生成 Backbone.history 对象；它将自动引用 Backbone.History 函数。Backbone.History 负责匹配路由和 router 对象中定义的活动。start() 方法触发后，将创建 Backbone.history 的 fragment 属性。它包含散列片段的值。该序列在根据状态次序管理浏览器历史方面十分有用。用户如果想要返回前一状态，单击浏览器的返回按钮。
在 清单 3 的示例中，通过一个启用 HTML5 特性 pushState 的配置调用 start() 方法。对于那些支持 pushState 的浏览器，Backbone 将监视 popstate 事件以触发一个新状态。如果浏览器不能支持 HTML5 特性，那么 onhashchange 活动会被监视。如果浏览器不支持该事件，轮询技术将监视 URL 散列片段的任何更改。

模型和集合
模型和集合是 Backbone.js 的重要组件，模型将数据（通常是来自服务器的数据）存储在键值对中。要创建一个模型，需要扩展 Backbone.Model，如 清单 4 所示。
#### 清单 4. Backbone.Model 创建
```
App.Models.Team = Backbone.Model.extend({
    defaults : {
       // default attributes
    }
    // Domain-specific methods go here
});
```
App.Models.Team 函数是一个新模型函数，但是必须创建一个实例才能在应用程序中使用特定模型，如 清单 5 所示。
#### 清单 5. 模型实例化
```
var team1 = new App.Models.Team();
```
现在，变量 team1 有一个名为 cid 的字段名，这是一个客户端标识符，形式为 "c" 再加上一个数字（例如，c0、c1、c2）。模型是通过存储在散列映射中的属性来定义的。属性可以在实例化时进行设置，或者使用 set() 方法设置。属性值可通过 get() 方法检索。清单 6 显示了如何通过实例化或 get()/set() 方法设置和获取属性。
#### 清单 6. 模型实例化和 get/set 方法
```
// "name" attribute is set into the model
var team1 = new App.Models.Team({
    name : "name1"
});
console.log(team1.get("name")); // prints "name1"

// "name" attribute is set with a new value
team1.set({
    name : "name2"
});
console.log(team1.get("name")); //prints "name2"
```
当使用 JavaScript 对象时，使用 set() 方法创建或者设置属性值的原因并不是显而易见的。其中一个原因是为了更新此值，如 清单 7 所示。
#### 清单 7. 以错误的方法更新属性
```
team1.attributes.name = "name2";
```
为了避免 使用 清单 7 中的代码，使用 set() 是改变模型状态并触发其变更事件的唯一方法。使用 set() 提升封装原则。清单 8 展示了如何将一个事件处理程序绑到发生变更的事件中。该事件处理程序包含一个 alert，在调用 set() 方法时会被触发，如 清单 6 所示。但是，在使用 清单 7 中的代码时不触发 alert。
#### 清单 8. 更改 App.Models.Team 模型中的事件处理程序
```
App.Models.Team = Backbone.Model.extend({
    initialize : function(){
        this.bind("change", this.changed);
    },
    changed : function(){
        alert("changed");
    }
});
```
Backbone 的另一个优势是易于通过 Ajax 交互与服务器进行通信。在模型上调用一个 save() 方法会通过 REST JSON API 异步将当前状态保存到服务器。清单 9 展示了此示例。
#### 清单 9. 在模型对象上调用 save 方法
```
barca.save();
```
save() 函数将在后台委托给 Backbone.sync，这是负责发出 RESTful 请求的组件，默认使用 jQuery 函数 $.ajax()。由于调用了 REST 风格架构，每个 Create、Read、Update 或 Delete (CRUD) 活动均会与各种不同类型的 HTTP 请求（POST、GET、PUT 和 DELETE）相关联。首先保存模型对象，使用一个 POST 请求，创建一个标识符 ID，其后，尝试发送对象到服务器，使用一个 PUT 请求。
当需要从服务器检索一个模型时，请求一个 Read 活动并使用一个 Ajax GET 请求。这类请求使用 fetch() 方法。要确定导入模型数据或者从中取出模型数据的服务器的位置：
如果模型属于一个 collection，那么集合对象的 url 属性将是该位置的基础，并且该模型 ID（不是 cid）会被附加以构成完整的 URL。
如果模型不是在一个集合中，那么该模型的 urlroot 属性被用作该位置的基础
清单 10 显示了如何获取一个模型。
#### 清单 10. 模型对象的 Fetch() 方法
```
var teamNew = new App.Models.Team({
    urlRoot : '/specialTeams'
});
teamNew.save(); // returns model's ID equal to '222'
teamNew.fetch(); // Ajax request to '/specialTeams/222'
```
validate() 方法被用于验证模型，如 清单 11 所示。需要重写 validate() 方法（在调用 set() 方法时触发）来包含模型的有效逻辑。传递给该函数的惟一参数是一个 JavaScript 对象，该对象包含了 set() 方法更新的属性，以便验证那些属性的条件。如果从 validate() 方法中没有返回任何内容，那么验证成功。如果返回一个错误消息，那么验证失败，将无法执行 set() 方法。
#### 清单 11. 模型的验证方法
```
App.Models.Team = Backbone.Model.extend({
    validate : function(attributes){
        if (!!attributes && attributes.name === "teamX") {
            // Error message returned if the value of the "name"
            // attribute is equal to "teamX"
            return "Error!";
        }
    }
}
```
一组模型被分组到到集合中，这个集合是 Backbone.Collection 的扩展函数。集合具有一个模型属性的特性，定义了组成该集合的模型类型。使用 add()/remove() 方法可以将一个模型添加和移动到集合中。清单 12 显示了如何创建和填充一个集合。
#### 清单 12. Backbone 集合
```
App.Collections.Teams = Backbone.Collection.extend({
    model : App.Models.Team
});
var teams = new App.Collections.Teams();

// Add e model to the collection object "teams"
teams.add(team1);
teams.add(new App.Models.Team({
    name : "Team B"
}));
teams.add(new App.Models.Team());
teams.remove(team1);

console.log(teams.length) // prints 2
```
创建的 teams 集合中包含一个含有两个模型的阵列，存储在模型属性中。尽管，在典型 Ajax 应用程序中，会从服务器动态（不是人工）填充该集合。fetch() 方法可以帮助完成此项任务，如 清单 13 所示，并将数据存储到模型阵列中。
#### 清单 13. Fetch() 方法
```
teams.fetch();
```
Backbone 中的集合拥有一个 url 属性，定义了使用 Ajax GET 请求从服务器取出 JSON 数据的位置，如 清单 14 所示。
#### 清单 14. 集合的 url 属性和 fetch() 方法
```
teams.url = '/getTeams';
teams.fetch(); //Ajax GET Request to '/getTeams'
```
Fetch() 方法属于异步调用，因此，在等待服务器响应时，应用程序不会中止。在一些情况下，要操作来自服务器的原始数据，可以使用集合的 parse() 方法。正如 清单 15 所示。
#### 清单 15. parse() 方法
```
App.Collections.Teams = Backbone.Collection.extend({
    model : App.Models.Team,
    parse : function(data) {
        // 'data' contains the raw JSON object
        console.log(data);
    }
});
```
集合提供的另一个有趣的方法是 reset()，它允许将多个模型设置到一个集合中。reset() 方法可以非常方便地将数据引导到集合中，比如页面加载，来避免用户等待异步调用返回。

视图和客户端模板
Backbone 中的视图与典型 MVC 方法的视图不一样。Backbone 视图可以扩展 Backbone.View 函数并显示模型中存储的数据。一个视图提供一个由 el 属性定义的 HTML 元素。该属性可以是由 tagName、className 和 id 属性相组合而构成的，或者是通过其本身的 el 值形成的。清单 16 显示了使用这不同方法组合 el 属性的两个不同视图。
#### 清单 16. Backbone 视图样例
```
// In the following view, el value is 'UL.team-element'
App.Views.Teams = Backbone.View.extend({
    el : 'UL.team-list'
});
// In the following view, el value is 'div.team-element'
App.Views.Team = Backbone.View.extend({
    className : '.team-element',
    tagName : 'div'
});
```
如果 el、tagName、className 和 id 属性为空，那么会默认将一个空的 DIV 分配给 el。
如上所述，一个视图必须与一个模型相关联。该模型属性也很有用，如 清单 17 所示。App.View.Team 视图被绑定到一个 App.Models.Team 模型实例。
#### 清单 17. Backbone 视图中的模型属性
```
// In the following view, el value is 'UL.team-element'
App.Views.Team = Backbone.View.extend({
    ...
    model : new App.Models.Team
});
```
要渲染数据（这是视图的主要目的），重写 render() 方法和逻辑来显示 DOM 元素（由 el 属性引用的）中的模型属性。清单 18 展示了一个 render 方法如何更新用户界面的样例。
#### 清单 18. Render() 方法
```
App.Views.Team = Backbone.View.extend({
    className : '.team-element',
    tagName : 'div',
    model : new App.Models.Team
    render : function() {
        // Render the 'name' attribute of the model associated
        // inside the DOM element referred by 'el'
        $(this.el).html("<span>" + this.model.get("name") + "</span>");
    }
});
```
Backbone 也可以促进客户端模板的使用，这就使得我们没有必要在 JavaScript 中嵌入 HTML 代码，如 清单 18 所示。（使用模板，模板会封装视图中常见函数；只指定此函数一次即可。）Backbone 在 underscore.js（一个必须的库）中提供一个模板引擎，尽管没有必要使用该模板引擎。清单 19 中的实例使用 underscore.js HTML 模板。
#### 清单 19. HTML 含有模板
```
<script id="teamTemplate" type="text/template">
    <%= name %>
</script>
```
清单 20 显示了另一个使用 underscore.js HTML 模板的样例。
#### 清单 20. 使用 _.template() 函数的视图
```
App.Views.Team = Backbone.View.extend({
    className : '.team-element',
    tagName : 'div',
    model : new App.Models.Team
    render : function() {
        // Compile the template
        var compiledTemplate = _.template($('#teamTemplate').html());
        // Model attributes loaded into the template. Template is
        // appended to the DOM element referred by the el attribute
        $(this.el).html(compiledTemplate(this.model.toJSON()));
    }
});
```
Backbone 中最有用且最有趣的一个功能是将 render() 方法绑定到模型的变更事件中，如 清单 21 所示。
#### 清单 21. Render() 方法绑定到模型变更事件
```
// In the following view, el value is 'div.team-element'
App.Views.Team = Backbone.View.extend({
    model : new App.Models.Team,
    initialize : function() {
        this.model.bind("change", this.render, this);
    }
})
```
上述代码将 render() 方法绑定到一个模型的变更事件中。当模型发生更改时，会自动触发 render() 方法，从而节省数行代码。从 Backbone 0.5.2 开始，bind() 方法就开始接受使用第三个参数来定义回调函数的对象。（在上述示例中，当前视图是回调函数 render() 中的对象）。在 Backbone 0.5.2 之前的版本中，必须使用 underscore.js 中的 bindAll 函数，如 清单 22 所示。
#### 清单 22. _.bindAll() usage
```
// In the following view, el value is 'div.team-element'
App.Views.Team = Backbone.View.extend({
    initialize : function() {
        _.bindAll(this, "render");
        this.model.bind("change", this.render);
    }
})
```
Backbone 视图中，通过视图中的 DOM 对象监听事件是比较容易的。对于实现这一点，events 属性很是方便的，如 清单 23 所示。
#### 清单 23. 事件属性
```
App.Views.Team = Backbone.View.extend({
    className : '.team-element',
    tagName : 'div',
    events : {
        "click a.more" : "moreInfo"
    },
    moreInfo : function(e){
         // Logic here
    }
})
```
events 属性的每个项均由两部分构成：
左边部分指定事件类型和触发事件的选择器。
右边部分定义了事件处理函数。
在 清单 23 中，当用户通过 DIV 中的类 more 以及类 team-element 点击链接时，会调用函数 moreInfo。

#### 结束语
MVC 模式可以为大型 JavaScript 应用程序提供所需的组织化代码。Backbone 是一个 JavaScript MVC 框架，它属于轻量级框架，且易于学习掌握。模型、视图、集合和路由器从不同的层面划分了应用程序，并负责处理几种特定事件。处理 Ajax 应用程序或者 SPI 应用程序时，Backbone 可能是最好的解决方案。
