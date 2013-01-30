express = require 'express'
path = require 'path'
http = require 'http'
fs = require 'fs'
swig = require 'swig'
cons = require 'consolidate'
prettyPrint = require('html').prettyPrint
lessMiddleware = require 'less-middleware'

_g = 
  pAlias: 'p'                               # 项目地址前缀
  sAlias: 's'                               # 静态文件地址前缀
  pPath: "#{__dirname}/projects"            # 模版引擎项目目录
  sDir: "flatsites"                         # 静态项目目录
  sPath: "#{__dirname}/public/flatsites"

app = express()
app.set 'port', process.env.PORT || 3000
app.set 'view engine', 'html'
app.engine 'html', cons.swig
app.use express.favicon()
app.use express.logger('dev')
app.use express.compress()
app.use express.bodyParser
  keepExtensions: true
  uploadDir: "#{__dirname}/public/upload"
app.use express.methodOverride()
app.use lessMiddleware
  src: "#{__dirname}/public"
app.use express.static("#{__dirname}/public")
app.use app.router
app.configure 'development', ->
  app.use express.errorHandler()

# 扫描项目目录
fs.readdir _g.pPath, (err, files) ->
  if err then throw err
  projects = []
  for p in files
    projects.push p
    pd = "#{_g.pPath}/#{p}"
    # 自动创建介绍信息文件
    fs.open "#{pd}/public/intro.html", 'a'
    # 生成less中间件
    app.use lessMiddleware
      src: "#{pd}/public/less"
      dest: "#{pd}/public/css"
      prefix: "/#{_g.sAlias}/#{p}/css"
    # 静态文件服务
    app.use "/#{_g.sAlias}/#{p}", express.static("#{pd}/public")
  app.set 'projectsList', projects

# 扫描静态项目目录
fs.readdir _g.sPath, (err, files) ->
  if err then throw err
  context = {}
  for i,s of files
    # 自动创建介绍信息文件
    fs.open "#{_g.sPath}/#{s}/intro.html", 'a'
    port = parseInt(app.get('port'), 10)+parseInt(i)+1
    context[s] = 
      name: s
      port: port
    appDir = express()
    # 文件服务开启
    appDir.use express.directory("#{_g.sPath}/#{s}")
    appDir.use express.static("#{_g.sPath}/#{s}")
    http.createServer(appDir).listen port
    console.log "静态项目 #{s}: #{port}"
  app.set 'sitesList', context

# ----------------------------------------------------------------

# 根据项目目录分配视图
assignViews = (req, resp, next) ->
  if req.params.page
    views = "#{_g.pPath}/#{req.params.project}/views"
  else
    views = "#{__dirname}/views"
  app.set 'views', views
  swig.init
    root: views
    filters:
      range0: (input) -> [0..input]
      range1: (input) -> [1..input]
  next()

# 项目汇聚页
app.get '/', assignViews, (req, resp) ->
  resp.render 'index', 
    'TITLE': 'NodeFED'
    'HOST': req.host
    pf: "/#{_g.pAlias}"
    sf: "/#{_g.sAlias}"
    sd: _g.sDir
    st: new Date().getTime()
    projects: app.get 'projectsList'
    sites: app.get 'sitesList'

# ajax请求模拟
app.all '/_ajax/:format', (req, resp) ->
  out = req.param('resp')
  if req.params.format is 'html'
    resp.send out
  if req.params.format is 'json'
    try
      JSON.parse out
      if req.query.jsoncallback
        resp.send "#{req.query.jsoncallback}(#{out})"
      else
        resp.send out
    catch error
      resp.json error: "json格式有误: #{error}"
  if req.params.format is 'json2'
    try
      json = JSON.stringify req.query
      if req.query.jsoncallback
        resp.send "#{req.query.jsoncallback}(#{json})"
      else
        resp.send json
    catch error
      resp.json error: "json格式有误: #{error}"
  if req.params.format is 'json3'
    try
      json = JSON.stringify req.body
      if req.body.jsoncallback
        resp.send "#{req.body.jsoncallback}(#{json})"
      else
        resp.send json
    catch error
      resp.json error: "json格式有误: #{error}"

# 请求代理(跨域专用)
app.get '/_proxy.php', (req, resp) ->
  http.get req.query.q, (res) ->
    console.log res.statusCode
    res.on 'data', (data) ->
      resp.send data.toString()

# 模拟上传
app.post '/_upload', (req, resp) ->
  fn = req.query.name
  try
    filename = path.basename req.files[fn].path
    if req.query.for is 'xheditor'
      resp.json
        err: ''
        msg: "/upload/#{filename}"
    else
      resp.json
        err: ''
        msg: "/upload/#{filename}"
  catch e
    resp.json err: e.message

# 列表&详细页
app.all "/#{_g.pAlias}/:project/:dir?/:page?", assignViews, (req, resp) ->
  project = req.params.project
  dir = req.params.dir
  page = req.params.page
  context = 
    'TITLE': "#{project} - #{page}"
    'PUBLIC': "http://#{req.host}:#{app.get('port')}/#{_g.sAlias}/#{project}"
    'PROJECT': project
    'DIR': dir
    'PAGE': page
    'GET': req.query
    'POST': req.body
    'BASE_URL': "/#{_g.pAlias}/#{project}/#{dir}"
    'PROJECT_URL': "/#{_g.pAlias}/#{project}"

  # 详细
  if page
    resp.render dir+'/'+page, context, (err, html) ->
      resp.send prettyPrint(html)

  # 二级目录
  else if dir
    stats = fs.statSync "#{_g.pPath}/#{project}/views/#{dir}"
    if stats.isFile()
      resp.send '页面必须放到目录下'
    fs.readdir "#{_g.pPath}/#{project}/views/#{dir}"
    , (err, files) ->
      for i,f of files
        files[i] = files[i].replace '.html', ''
      context.files = files.filter -> yes
      resp.render 'list', context

  # 列表
  else
    fs.readdir "#{_g.pPath}/#{project}/views"
    , (err, files) ->
      for i,f of files
        if f in ['layouts']
          delete files[i]
        else 
          files[i] = files[i].replace '.html', ''
      context.files = files.filter -> yes
      resp.render 'list', context

# ------------------------------------------------------------------

http.createServer(app).listen app.get('port'), ->
  console.log "NodeFED: #{app.get('port')}"