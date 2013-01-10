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


