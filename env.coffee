# env.js

# Files in server .html .js
module.exports.F = F = {}
F.index_html_path = "./html/index.html"
F.fixURLtoFileName = (path) ->
  "./html" + path.replace /\/$/, "/index.html"
F.isRealFileName = (filename) ->
  F.realfilenames.some (realname) ->
    filename is realname
F.realfilenames = [
  F.index_html_path
  "./html/tw-minus.user.js"
  "./html/tw-minus-patch.js"
  "./html/favicon.ico"
]

# Location of tw-minus
module.exports.L = L = {}
L.twMinusIsOnWeb = "PORT" of process.env
L.PORT = if L.twMinusIsOnWeb then process.env.PORT | 0 else 3000
L.TW_MINUS_URL = process.env.URL or "http://localhost:#{L.PORT}"
L.TW_API_URL = "https://api.twitter.com"
