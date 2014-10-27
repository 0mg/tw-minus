# Object Functions
O = {}
O.sa = (o, iv) -> o[i] = iv[i] for i of iv
O.stringify = (arg) ->
  if typeof arg is "string"
    return if arg.match(///
    ^(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)
    \ (?:Jun|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)
    \ (?:0[1-9]|[12][0-9]|3[01])
    ///) then new Date(arg).toLocaleString() else arg

  if arg is null || typeof arg isnt "object" then return arg
  proplist = []
  proplist.push(i + ": " + O.stringify(arg[i])) for i of arg
  "{\n" + proplist.join("\n").replace(/^/gm, "  ") + "\n}"

O.htmlify = (arg) ->
  if arg is null or typeof arg isnt "object"
    if typeof arg is "string" then return D.ct('"' + arg + '"')
    return D.ct(arg)
  list = D.ce("dl")
  for i of arg
    list.add(D.ce("dt").add(D.ct(i)), D.ce("dd").add(O.htmlify(arg[i])))
  if list.hasChildNodes() then list else D.ce("em").add(D.ct("{}"))

# Text Functions
T = {}
# normalize URL
T.fixURL = (url) ->
  urlParts = url.match /([^?#]*)[?]?([^#]*)#?([\S\s]*)/
  baseURL = raw: urlParts[1]
  search = raw: urlParts[2]
  hash = raw: urlParts[3]
  baseURL.encoded = baseURL.raw
  search.decobj = T.parseQuery(search.raw)
  if search.raw
    search.encoded = "?" + T.strQuery(search.decobj)
  else
    search.encoded = ""

  if hash.raw
    hash.encoded = "#" + hash.raw
  else
    hash.encoded = ""

  encurl = new String(baseURL.encoded + search.encoded + hash.encoded)
  encurl.base = baseURL.encoded
  encurl.query = search.decobj
  encurl.hash = hash.encoded
  encurl

# a=1&b=%40 -> {a:"1",b:"@"}
T.parseQuery = (qtext) ->
  if !qtext then return {}
  qobj = {}
  pts = qtext.split("&")
  for q in pts
    pts = q.split("=")
    name = decodeURIComponent(pts[0])
    value = decodeURIComponent(pts[1] || "")
    if name
      if name of qobj
        qobj[name] = [qobj[name]..., value]
      else
        qobj[name] = value
  qobj

# {a:"1",b:"@"} -> a=1&b=%40
T.strQuery = (qobj) ->
  if !qobj then return ""
  qarr = for v, i of qobj
    for val in [].concat(qobj[i])
      P.oauth.enc(i) + "=" + P.oauth.enc(val)

  qtext = qarr.join("&")

# eg. '2011/5/27 11:11' to '3 minutes ago'
T.gapTime = (p) ->
  g = Date.now() - p
  gap = new Date(0, 0, 0, 0, 0, 0, g)
  if g < 60000 then gap.getSeconds() + " seconds ago"
  else if g < 60000 * 60 then gap.getMinutes() + " minutes ago"
  else if g < 60000 * 60 * 24 then gap.getHours() + " hours ago"
  else p.toLocaleString()

# eg. '&lt;' to '<'
T.decodeHTML = (innerText) ->
  innerText or= ""
  re =
    entity: /^&([a-zA-Z]+);/
    entityDec: /^&#(\d+);/
    entityHex: /^&#x([\da-fA-F]+);/
    text: /^[^&]+/

  ctx = innerText
  xssText = ""
  while ctx.length
    if s = re.entity.exec(ctx)
      str = s[0]
      xssText += T.dentity(s[1]) || str
    else if s = re.entityDec.exec(ctx)
      str = s[0]
      xssText += T.dentityDec(+s[1]) || str
    else if s = re.entityHex.exec(ctx)
      str = s[0]
      xssText += T.dentityDec(parseInt(s[1], 16)) || str
    else if s = re.text.exec(ctx)
      str = s[0]
      xssText += str
    else
      str = ctx.substring(0, 1)
      xssText += str
    ctx = ctx.substring(str.length)

  xssText

T.dentityDec = (dec) ->
  if typeof dec isnt "number" then return false
  String.fromCharCode(dec)

T.dentity = (entity) ->
  charCode = D.HTML_ENTITIES[entity]
  if typeof charCode is "number" then String.fromCharCode(charCode)
  else null

T.decrement = (s) ->
  s = s.split("")
  for i in [s.length - 1..0]
    n = s[i] - 1
    if n < 0 and i > 0 then s[i] = 9 else s[i] = n; break
  s.join("")

T.supchar = {}
T.supchar.is = (c) -> /^[\ud800-\udbff][\udc00-\udfff]$/.test(c)

T.supchar.encode = (unicode) ->
  if unicode < 0x10000 then return [unicode]
  hi = (unicode - 0x10000) / 0x400 + 0xd800
  lo = (unicode - 0x10000) % 0x400 + 0xdc00
  [hi, lo]

T.supchar.decode = (c) ->
  if T.supchar.is(c)
    hi = c.charCodeAt(0)
    lo = c.charCodeAt(1)
    0x10000 + ((hi - 0xd800) * 0x400) + (lo - 0xdc00)
  else if c.length is 1
    c.charCodeAt(0)
  else
    throw Error("invalid string")

T.userQryStr = (user_name_or_id) ->
  s = user_name_or_id
  if s[-1...] is "@" then "user_id=" + s[0...-1] else "screen_name=" + s
