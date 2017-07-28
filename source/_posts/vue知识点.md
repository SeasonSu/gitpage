---
title: vue知识点
tags:
  - ''
categories:
  - ''
date: 2017-04-27 19:36:23
---

#### vue是什么？

vue也是一个数据驱动框架，做spa页面的
vue如果不做页面可以当做一个单独使用的js库，做双向数据绑定用
Vue的核心库只关注视图层,但是vue并不只关注视图，和angular一样也有指令，过滤器这些东西
vue有非常强大的单文件组件
就是css+html+js都写在一个.vue文件中，这样定义的组件很简洁，清晰，组件化分的很彻底
而angular中的js文件只能写js
虽然react中可以写css-in-js，但是缺乏选择器功能，即便可以在js中引入css文件，但还是不方便
vue融合了react和angular的优点，并且解决了react和angualr的痛点
<!--more-->

#### vue学习地址和技术栈

Vue2.0中文网：
vue全家桶变为vue2.0+vue-router+fetch+vuex
我们下文中所出现的vue都指代vue2.0
vue和其他框架的对比

vue比市面上的其他框架功能更完善，性能更高效
#### vue快速开始

用vue-cli开始

```
# 全局安装 vue-cli
$ npm install --global vue-cli
# 创建一个基于 webpack 模板的新项目
$  vue init webpack my-project
# 安装依赖，走你
$ cd my-project
$ npm install
$ npm run dev
```
你只需要关注你配置的东西就可以了，不需要关注webpack的配置项，因为webpack的配置很难，很多人不会，也是为了简便开发
自己创建Vue的开发环境

#### 准备工作

升级webstorm到最新版本，老版本对.vue文件的开发是有bug的
下载webstorm为Vue提供的插件vue-for-idea，这个插件可以让webstorm支持以.vue结尾的文件能够运行
下载vuenpm install vue -save
下载编译模块npm install vue-template-compiler -save
src/js文件中创建main.js
```
import Vue from 'vue'
import AppContainer from '../containers/AppContainer'

const app = new Vue({
    render: h => h(AppContainer),
}).$mount('#app')


// new Vue({
//     el:'#app',
//     render: h => h(App)
// })
```
在src/container中创建AppContainer.vue文件
```
<template>
    <div>
        {{msg}}
    </div>
</template>
<style>
    body{
        background-color:#ff0000;
    }
</style>
<script>
    export default{
        data(){
            return{
                msg:'hello vue'
            }
        }
    }
</script>
```
当你第一次创建.vue文件的时候IDE会问你用什么语法去解析，你选择html语法
接下来就可以直接运行npm run develop了
你可以去google中搜索vue-devtools下载并安装，用于帮你监听组件的data属性变化
#### vue中的基础知识点

Vue实例

#####  属性与方法

我们自定义的一些数据和方法是要绑定到实例的不同属性上面去的
例如数据都要绑定要data属性，方法都要绑定到methods方法
实例上的data和methods里面的key值会自动挂载到vue实例上，我们管他们叫动态属性，获取方式直接使实例.动态属性名
vue实例上的实例属性要通过实例.$实例属性名获取
在vue实例里面用this，this指向的是vue实例
可以通过this.a去获取动态属性
可以通过this.$data去获取实例属性
实例上有一个$watch方法可以监听data属性里面的数据的变化，data一变会自动触发监听事件的执行
```
var data = {a: 1}
    const app = new Vue({
        // 和数据相关的都挂载到data上
        data: data,
        // 和方法相关的都挂载到methods上
        methods: {
            // this和$的使用
            func1: function () {
                console.log(this.a);
                console.log(this.$data.a);
            },
            changeData:function () {
                this.a=2
            }
        }
    })

    // 先监听再改变
    app.$watch('a', function (newVal, oldVal) {
        console.log(newVal)
        console.log(oldVal)
    })
    // 值改变之后会自动执行监听方法
    // data的值是可以直接改变的，和react的setState方法不一样，因为vue里面用了set和get方法，可以起到自动监听的作用
    app.a=3


    // 动态属性和实例属性
//    console.log(app)
//    console.log(app.a)
//    console.log(app.$data.a)
```
##### 实例生命周期

和react的生命周期基本思想是一样的
只不过react中是监听props和state属性的变化
而在vue中是只监听data属性的变化
vue中的生命周期函数要比react中的方法多
这些生命周期方法只能在spa应用中起作用，单独作为双向数据绑定库无法生效
`vue生命周期图`
![](https://static.oschina.net/uploads/img/201704/24103726_vz9U.png)

##### 模板语法

就是如何在.vue文件的template标签中书写内容

v-once指令只会执行一次性地插值，当数据改变时，插值处的内容不会更新。但请留心这会影响到该节点上所有的数据绑定：
v-html会按照html规则去解析内容
我们在为标签的属性赋值的时候不能Mustache语法，我们要用v-bind指令
v-bind绑定的属性必须是data属性里面定义的值，如果想写固定的值加单引号
```
// 错误的写法
<div id="{{id}}"></div>
// 正确的写法
<div v-bind:id="id"></div>
```
在Mustache中可以处理一些简单的js表达式，Mustache中的属性本身有什么方法，在里面也是可以直接使用的
```
{{ number + 1 }}
{{ ok ? 'YES' : 'NO' }}
{{ message.split('').reverse().join('') }}
<div v-bind:id="'list-' + id"></div>
```
在Mustache中可以使用自定义过滤器，也可以多过滤器串联。但是过滤器不能用在v-bind中，如果想实现相同的效果在v-bind中我们要用计算属性
```
{{ message | capitalize }}

{{ message | filterA | filterB }}

new Vue({
  // ...
  filters: {
    capitalize: function (value) {
      if (!value) return ''
      value = value.toString()
      return value.charAt(0).toUpperCase() + value.slice(1)
    }
  }
})
```
在dom标签中可以使用指令，如v-if，v-for
```
<a v-on:click="doSomething">
```
在dom的事件中可以使用修饰符去帮你简化一些操作
```
<form v-on:submit.prevent="onSubmit"></form>
```
v-bind和v-on在模板语法中可以缩写
```
//完整语法
<a v-bind:href="url"></a>
//缩写
<a :href="url"></a>
//完整语法
<a v-on:click="doSomething"></a>
// 缩写
<a @click="doSomething"></a>
```


#### 计算属性

计算属性可以处理模板语法中的复杂业务逻辑，跟Mustache语法比
计算属性 vs methods

我们看到计算属性和methods的效果基本你一样，那么他们的区别是什么？
计算属性的依赖如果没有发生变化，当你再次调用计算属性的时候，能够立即返回上次缓存的计算值，而不需要从新执行计算属性的方法
而方法需要从新执行方法体
样例
```
<template>
    <div>
        <p>Original message: "{{ message }}{{name}}"</p>
        <p>Computed reversed message: "{{ reversedMessage }}"</p>
        <p>Computed reversed message: "{{ reverseMessage() }}"</p>
    </div>
</template>
<style>
    body{
        background-color:#ff0000;
    }
</style>
<script>
    export default{
        data(){
            return{
                message: 'Hello',
                name:'a'
            }
        },
        mounted(){
            this.name="b"
        },
        computed: {
            reversedMessage: function () {
                console.log('计算属性被调用了')
                return this.message.split('').reverse().join('')
            }
        },
        methods: {
            reverseMessage: function () {
                console.log('方法被执行了')
                return this.message.split('').reverse().join('')
            }
        }

    }
</script>
```
计算属性 vs watch

watch方法每次只能监听一个data值的变化
而计算属性可以同时监听多个data值的变化
用计算属性可以简化watch中重复的代码
```
<!--页面-->
<div id="demo">{{ fullName }}</div>
  //watch写法
  var vm = new Vue({
    el: '#demo',
    data: {
      firstName: 'Foo',
      lastName: 'Bar',
      fullName: 'Foo Bar'
    },
    watch: {
      firstName: function (val) {
        this.fullName = val + ' ' + this.lastName
      },
      lastName: function (val) {
        this.fullName = this.firstName + ' ' + val
      }
    }
  })
  //计算属性的写法
  //本质是你要获取全名
  var vm = new Vue({
    el: '#demo',
    data: {
      firstName: 'Foo',
      lastName: 'Bar'
    },
    computed: {
      fullName: function () {
        return this.firstName + ' ' + this.lastName
      }
    }
  })
```
计算setter

计算属性默认是只有getter的，那么data属性里面你的值发生改变了，计算属性要从新执行
而setter的作用是调用计算属性的时候给一个初始值，那么data属性里面的值也会跟着做相应的改变
```
// 接上面的代码段
computed: {
  fullName: {
    // getter
    get: function () {
      return this.firstName + ' ' + this.lastName
    },
    // setter
    set: function (newValue) {
      var names = newValue.split(' ')
      this.firstName = names[0]
      this.lastName = names[names.length - 1]
    }
  }
}
```
vue实例上的观察watch还是很有用的，在进行执行异步操作或昂贵操作时，我们要用watch这个实例属性
因为你不要忘记计算属性出现的原因是为了解决mustache语法中有过多的逻辑操作问题，它只能进行一些小型操作的内容
Class与Style绑定

绑定要用v-bind:class和:bind:style
v-bind:class指令可以与普通的class属性共存
绑定的时候可以给对象，可以个数组，还可以有条件判断和三元表达式
条件渲染

v-if和v-else只能控制一个标签的渲染，而且v-else要紧跟着v-if
如果想要控制一部分标签的渲染，需要用<template>标签包裹，v-if作用在template标签上
v-show也可以控制标签的显示隐藏，不过只是简单的切换样式
v-show的元素会始终渲染并保持在 DOM 中，v-if的元素会被移除
注意 v-show 不支持 <template> 语法
v-if是惰性的，只有在条件第一次为true的时候才进行局部渲染吧
v-if有更高的切换消耗，v-show有更高的初始渲染消耗。因此如果需要频繁切换使用v-show较好，如果在运行时条件不大可能改变则使用v-if较好。
列表渲染

v-for是vue中做循环的，值可以给数组，对象，数值三种类型
可以用of替换in
如果想循环渲染一部分标签，要用template标签包裹，v-for作用在template标签上
在循环渲染引入的自定义组件的时候要手动为组件传递item的属性值
```
    <my-components
      is="todo-item"
      v-for="(item, index) in todos"
      v-bind:title="item"
      v-on:remove="item.splice(index, 1)"
    >
    </my-components>
```
在循环渲染的时候要动态的绑定v-bind:key,这样可以提升vue的渲染效率
Vue 包含一组观察数组的变异方法，只要调用它们将会触发视图更新，并且改变了原数组
push() pop() shift() unshift() splice() sort() reverse()
重塑数组不会改变原来的数据，而是返回一个改变之后的新数据
filter(), concat(), slice()
重塑数组一般是赋值用，这样才能触发vue的重新渲染，而你并不需要担心性能问题，因为vue会智能的重用数组
由于JavaScript 的限制，Vue不能检测以下变动的数组：
当你直接设置一个项的索引时，例如： vm.items[indexOfItem] = newValue
用Vue.set解决
当你修改数组的长度时，例如： vm.items.length = newLength
用splice解决
v-for结合计属性或者methods时可以做数据的过滤和排序
```
// <li v-for="n in evenNumbers">{{ n }}</li>

data: {
  numbers: [ 1, 2, 3, 4, 5 ]
},
computed: {
  evenNumbers: function () {
    return this.numbers.filter(function (number) {
      return number % 2 === 0
    })
  }
}
```
#### 事件处理器

在v-on:click的时候想既传递参数又想传递事件对象，那么你需要手动传入$event参数
```
<button v-on:click="warn('Form cannot be submitted yet.', $event)">Submit</button>
methods: {
  warn: function (message, event) {
    // 现在我们可以访问原生事件对象
    if (event) event.preventDefault()
    alert(message)
  }
}
```
#### 常用事件修饰符
```
<!-- 阻止单击事件冒泡 -->
<a v-on:click.stop="doThis"></a>
<!-- 提交事件不再重载页面 -->
<form v-on:submit.prevent="onSubmit"></form>
<!-- 修饰符可以串联  -->
<a v-on:click.stop.prevent="doThat"></a>
<!-- 只有修饰符 -->
<form v-on:submit.prevent></form>
<!-- 添加事件侦听器时使用时间捕获模式 -->
<div v-on:click.capture="doThis">...</div>
<!-- 只当事件在该元素本身（而不是子元素）触发时触发回调 -->
<div v-on:click.self="doThat">...</div>
<!-- the click event will be triggered at most once -->
<a v-on:click.once="doThis"></a>
```

#### 常见的按键修饰符
```
<!-- 只有在 keyCode 是 13 时调用 vm.submit() -->
<input v-on:keyup.13="submit">
<!-- 同上 -->
<input v-on:keyup.enter="submit">
<!-- 缩写语法 -->
<input @keyup.enter="submit">

<!--全部的按键别名：-->

    enter
    tab
    delete (捕获 “删除” 和 “退格” 键)
    esc
    space
    up
    down
    left
    right
    ctrl
    alt
    shift
    meta
通过全局 config.keyCodes自定义按键修饰符别名,记住要在new新实例之前注册
// 可以使用 v-on:keyup.f1
Vue.config.keyCodes.f1 = 112
```
#### 表单控件绑定

表单的双向绑定用v-model指令
在文本区域插值<textarea></textarea>并不会生效，应用v-model来代替
单个复选按钮绑定的是选中状态，多个复选按钮绑定的是值
列表没有value值绑定的是标签内容，有value值绑定的就是value值
如果想让表单的value属性绑定到Vue实例的动态属性上，需要用v-bind:value绑定
```
<input type="radio" v-model="pick" v-bind:value="a">
```
.lazy修饰符可以实现单向数据绑定
```
<!-- 在 "change" 而不是 "input" 事件中更新 -->
<input v-model.lazy="msg" >
```
组件

组件可以扩展 HTML 元素，封装可重用的代码。在较高层面上，组件是自定义元素， Vue.js 的编译器为它添加特殊功能。在有些情况下，组件也可以是原生 HTML 元素的形式，以 is 特性扩展。
组件是类似于angualr中自定义指令，是vue中的一种自定义标签
相当于react中的通用组件，高可复用性的（例如：列表，按钮，等待器）
组件的使用

#### 全局注册组件

全局组件的定义一定要在创建根实例之前
在全局注册的组件可以在子组件的页面中随意使用
```
Vue.component('soupfree', {
        template: '<div>汤免费</div>'
    })

    const app = new Vue({
        el:'#example'
    })
```
##### 局部注册组件

在要使用的组价中增加components属性，注册引入的组件并改名，之后才可以在html代码中使用
一般局部注册的组件都是通过.vue文件实现的
```
<template>
    <div>
       姓名：汤免费，年龄：{{age}},性别：{{genderSex}}
    </div>
</template>
<style scope>
    div{
        background-color:orange;
    }
</style>
<script>
    export default{
        data(){
            return{

            }
        },
        props:['age','genderSex']
    }
</script>
<template>
    <div>
        <soup-free></soup-free>
        {{msg}}
    </div>
</template>
<style>
    body{
        background-color:#ff0000;
    }
</style>
<script>
    import soupfree from '../components/soupfree.vue'
    export default{
        data(){
            return{
                msg:'hello vue'
            }
        },
        components:{
            'soup-free':soupfree
        }
    }
</script>
```
##### Dom模板解析问题

当你在一些特殊标签如table，ul，ol，select中使用自定义组件的时候会有一些限制

例如
```
<table>
     <my-row>...</my-row>
</table>
```
因为Vue只有在浏览器解析和标准化HTML后才能获取模版内容
再准确的说也就是用Vue.component方法自定义的组件
is特性可以解决这个问题
```
  <table>
    <tr is="my-row"></tr>
  </table>
```
应当注意，如果您使用来自以下来源之一的字符串模板，这些限制将不适用：
```
<script type="text/x-template">
```
因为这里面的代码是内连载页面中的
JavaScript内联模版字符串
这个就是template属性
.vue 组件
在webpack构建的时候就已经处理了组件内容为html了
因此，有必要的话请使用字符串模版。
☆在自定义组件中data属性必须是函数形式☆

也就是在Vue.component中和.vue文件中的data属性
如果是父子组件，那么父组件向子组件传递参数用props,子组件向父组件传递参数用$emit广播
props属性

参数在传递的过程中，父组件传递参数用kebab-case（短横线隔开），在子组件接收的时候用camelCase
如果传递的属性来自父组件的data属性，也就是向子组件传递动态属性那么需要用v-bind去传递
如何传递的属性类型是数值型，那么也需要用v-bind去传递把
<!-- 传递实际的数字 -->
<comp v-bind:some-prop="1"></comp>
☆注意在JavaScript中对象和数组是引用类型，指向同一个内存空间，如果prop是一个对象或数组，在子组件内部改变它会影响父组件的状态。
注意一般情况下不要在子组件中改变父组件中传递过来的props，但是有两种特殊情况会改变
我们在传递属性的时候可以做属性校验
当prop验证失败了,Vue将拒绝在子组件上设置此值，如果使用的是开发版本会抛出一条警告。
自定义事件

用v-on去绑定自定义事件
使用$on(eventName)监听事件
使用$emit(eventName)触发事件
在自定义组件上是不可以用v-model指令，但是这个效果可以通过自定义组件在内部用自定义事件模拟实现
```
Vue.component('currency-input', {
  template: '\
    <span>\
      $\
      <input\
        ref="input"\
        v-bind:value="value"\
        v-on:input="updateValue($event.target.value)"\
      >\
    </span>\
  ',
  props: ['value'],
  methods: {
    // 不是直接更新值，而是使用此方法来对输入值进行格式化和位数限制
    updateValue: function (value) {
      var formattedValue = value
        // 删除两侧的空格符
        .trim()
        // 保留 2 小数位
        .slice(0, value.indexOf('.') + 3)
      // 如果值不统一，手动覆盖以保持一致
      if (formattedValue !== value) {
        this.$refs.input.value = formattedValue
      }
      // 通过 input 事件发出数值
      this.$emit('input', Number(formattedValue))
    }
  }
})
```
兄弟组件之间的通信可以通过bus中央事件总线实现
但是更复杂的数据通信最好还是用vuex
```
// 在根组件中注册bus属性
const app = new Vue({
    data:{
        bus:new Vue()
    },
    render: h => h(AppContainer),
}).$mount('#app')
// 在子组件中使用
this.$root.bus.$emit('eventName',2323)
```
slot分发

在自定义组件使用的时候，如果页面中有内容，又想让内容在自定义组件中使用，我们需要养slot标签
slot标签在一个html标签中只能出现一次
作用域插槽是一种特殊类型的插槽，用作使用一个（能够传递数据到）可重用模板替换已渲染元素。
通俗的说就是子组件里面的数据可以通过作用域插槽用在父组件页面中的指定区域内
动态组件

组件可以通过is特性动态加载
你可以用keep-alive指令缓存组件
杂项

你可以通过ref属性标记一个组件，之后可以用this.$refs.标记的名称或得到该组件
当ref和v-for一起使用时，ref是一个数组或对象，包含相应的子组件。
$refs只在组件渲染完成后才填充，并且它是非响应式的。它仅仅作为一个直接访问子组件的应急方案——应当避免在模版或计算属性中使用$refs
##### 组件的异步加载

##### 组件命名规范

##### 组件的递归调用

组件上的name属性还是这个组件在全局注册时候的名字
```
<unique-name-of-my-component name="unique-name-of-my-component"></unique-name-of-my-component>
```
##### 组件的循环引用

Vue.component全局注册组件后，这个问题会自动解决，你要做的就是在写代码的时候不要出现组件循环引用
内联模板

通俗的说就是在定义组件的时候不用给template属性了
x-Templates
