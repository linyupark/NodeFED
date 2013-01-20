NodeFED
============
NodeFED是使用Node.js的前端开发展示平台，模版引擎为swig，也可以展示静态html的项目。
目前仅支持windows平台一件启动，默认开启的是3000端口以及静态项目目录3000+n端口（项目有几个端口就累计添加）

创建新模版引擎项目
==================
在 projects 目录下放置 **英文** 目录作为项目名称
例如：

    projects
      |- sample
        |- public
          |- logo.png
          |- intro.html
          |- ....
        |- views
          |- layouts
            |- xx.html
          |- xx.html


* sample 就为项目名称，public 为放置静态资源的目录，views 为放置视图文件的目录。
* public 下的 logo.png、 intro.html 分别为项目展示用的图标跟说明文字信息。
* views 下的 layouts 目录放置的是视图布局文件，其他则为页面文件。

放置静态项目目录
================
直接将目录放置到 public/flatsites 下即可。其中 logo.png 跟 intro.html 的作用跟上面一致。


全局变量
=========
    
    {{TITLE}} => 项目名+页面名
    {{PUBLIC}} => 静态资源目录url
    {{PROJECT}} => 项目名称
    {{PAGE}} => 页面名称
    {{GET}} => (GET请求值)http://xxx?xx=xx {{GET.xx}} => xx
    {{POST}} => (POST请求值)
    {{PROJECT_URL}} => 项目URL地址，{{PROJECT_URL}}/首页 => 显示可跳转到首页的地址

ajax请求模拟
=============
请求地址格式：/_ajax/类型?resp=data
*类型 为必填项，html与json两个可选类型
*反馈 为模拟发送的数据信息，发送为何信息，反馈也为何信息。
例如：
    
    $.get('/_ajax/html', {resp: '<h1>你好</h1>'}, function(resp){
      console.log(resp); // <--- <h1>你好</h1>
    });

json类型数据也相同道理。

上传
=======
发送上传文件至 /_upload即可，文件会放置到/public/upload目录下，文件类型不变，文件名为随机数。
并会返回可获取到文件的url地址json格式数据：

    {"url": "/upload/文件名"}
