# index.js

fs = require "fs"
http = require "http"
https = require "https"
URL = require "url"
{F, L} = require "./env.js"
P = require "./P.js"

# make Response Header
Header = (filename) ->
  arr = (String filename).split "."
  if arr.length <= 1
    ext = "txt"
  else
    ext = arr[-1..].toLowerCase()
  switch ext
    when "html"
      ctype = "text/html; charset=utf-8"
    when "json"
      ctype = "application/json; charset=utf-8"
    when "js"
      ctype = "text/javascript; charset=utf-8"
    when "ico"
      ctype = "image/x-icon"
      #"image/vnd.microsoft.icon"
    when "txt"
      ctype = "text/plain; charset=utf-8"
    else
      ctype = "text/plain; charset=utf-8"
  {
    "content-type": ctype
    "x-content-type-options": "nosniff"
    "x-frame-options": "deny"
    "x-xss-protection": "1; mode=block"
    "strict-transport-security": "max-age=2592000"
  }

# Server Response -> to browser
srvres =
  main: (req, res, data, filename) ->
    res.writeHead 200, new Header filename
    res.write data
    res.end()
  404: (req, res, data, filename, err) ->
    res.writeHead 404, new Header ".txt"
    res.write "file #{req.url} is not exist"
    res.end()
  goAuthorize: (req, res) ->
    header = new Header ".txt"
    header["Location"] = L.TW_API_URL + req.url
    res.writeHead 302, header
    res.write "redirect to [Authorize app] page"
    res.end()
  forceHTTPS: (req, res, err) ->
    header = new Header ".txt"
    header["Location"] = L.TW_MINUS_URL + req.url
    res.writeHead 302, header
    res.write "redirect to HTTPS"
    res.end()
  xhr: (req, res, rcvdata) ->
    params = Object.create req
    tokens = (String params.headers.authorization).split ","
    if tokens.length is 3
      [params.oauth_phase, params.token, params.token_secret] = tokens
    params.data = rcvdata
    sendTwitter params, res

# Server call Twitter API -> response to browser
sendTwitter = (params, browser) ->
  url = L.TW_API_URL + params.url
  urlo = URL.parse url, on
  if params.headers["content-type"] is "application/x-www-form-urlencoded"
    postqry = (URL.parse "?" + params.data, on).query
  else
    postqry = {}
  headers =
    "accept-encoding": params.headers["accept-encoding"]
  headers["content-type"] = params.headers["content-type"]
  headers["authorization"] = P.getOAuthHeader(
    params.method,
    url,
    postqry,
    params.oauth_phase,
    params.token,
    params.token_secret
  )
  options =
    host: urlo.host
    path: params.url
    method: params.method
    headers: headers
  req = https.request options, (res) ->
    browser.writeHead res.statusCode, res.headers
    res.on "data", (d) ->
      browser.write(d)
    res.on "end", ->
      browser.end()
  req.write params.data
  req.end()

# Server listen <- request from browser
http.createServer (req, res) ->
  if L.twMinusIsOnWeb and req.headers["x-forwarded-proto"] isnt "https"
    srvres.forceHTTPS req, res, ""
    return
  data = new Buffer ""
  filename = F.fixURLtoFileName req.url
  if filename in F.realfilenames
    # File request
  else if req.method isnt "GET" or
  req.headers["x-requested-with"] is "XMLHttpRequest"
    # XHR request
    req.on "data", (d) -> data = Buffer.concat [data, d]
    req.on "end", -> srvres.xhr req, res, data
    return
  else if /^\/oauth\/authorize($|\?)/.test req.url
    # Access to Special URL
    srvres.goAuthorize req, res
    return
  else
    # 404 Not Found
    filename = F.index_html_path
  fs.readFile filename, (err, data) ->
    if err
      srvres[404] req, res, data, filename, err
    else
      srvres.main req, res, data, filename
.listen L.PORT
