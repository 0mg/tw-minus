# XHR Functions
X = {}

# make OAuth access token
X.getOAuthHeader = (method, url, q, oauthPhase) -> {
  var lsdata = LS.load()
  var consumer_key = lsdata["consumer_key"] || P.oauth.consumer_key
  var consumer_secret = lsdata["consumer_secret"] || P.oauth.consumer_secret
  var oauth_token
  var oauth_token_secret
  var oadata = {
    "oauth_consumer_key": consumer_key,
    "oauth_nonce": Math.random().toString(36),
    "oauth_signature_method": "HMAC-SHA1",
    "oauth_timestamp": (Date.now() / 1000).toFixed(0),
    "oauth_version": "1.0"
  }
  switch (oauthPhase) {
  case "get_request_token":
    oauth_token_secret = ""
    oadata["oauth_callback"] =
      "https://api.twitter.com" + U.ROOT + "login"
    break
  case "get_access_token":
    oauth_token = lsdata["request_token"]
    oauth_token_secret = lsdata["request_token_secret"]
    oadata["oauth_token"] = oauth_token
    break
  default:
    oauth_token = lsdata["access_token"]
    oauth_token_secret = lsdata["access_token_secret"]
    oadata["oauth_token"] = oauth_token
    break
  }
  if (typeof q is "string") {
    q = T.parseQuery(q)
  }
  url = D.ce("a").sa("href", url).href
  oadata["oauth_signature"] =
    P.oauth.genSig(
      method, url, oadata, q, consumer_secret, oauth_token_secret)
  var heads = []
  for (var i in oadata) {
    heads.push(P.oauth.enc(i) + "=\"" + P.oauth.enc(oadata[i]) + "\"")
  }
  var header = "OAuth " + heads.join(",")
  return header
}

# multipart/form-data
X.formData = (qrys) -> {
  var fd = new FormData
  for (var i in qrys) {
    var qry = qrys[i]
    if (qry instanceof FileList) [].forEach.call(qry, (blob) -> {
      fd.append(i, blob)
    })
    else fd.append(i, qry)
  }
  return fd
}

X.onloadstart = (method, url, q) -> {
  V.misc.onXHRStart(method, url, q)
}
X.onloadend = (xhr, method, url, q) -> {}

X.onload = (method, url, q, f, b) -> {
  if (!(this instanceof XMLHttpRequest)) throw method + ":not XHR obj"
  var onScs = (xhr, method, url) -> {
    alert([xhr.status, url, xhr.responseText].join("\n"))
  }
  var onErr = (xhr, method, url) -> {
    alert([xhr.status, url, xhr.responseText].join("\n"))
  }
  if (this.status is 200) {
    if (f) f(this); else if (f is undefined) onScs(this, method, url)
    API.cc.reuseData.apply(this, arguments)
    V.misc.onXHREnd(true, this, method, url, q)
  } else {
    if (b) b(this); else if (b is undefined) onErr(this, method, url)
    V.misc.onXHREnd(false, this, method, url, q)
  }
}

X.onerror = (method, url, q, f, b) -> {
  if (!(this instanceof XMLHttpRequest)) throw method + ":not XHR obj"
  var onErr = (xhr, method, url) -> {
    alert([xhr.status, url, xhr.responseText].join("\n"))
  }
  if (b) b(this); else if (b is undefined) onErr(this, method, url)
  V.misc.onXHREnd(false, this, method, url, q)
}

# HEAD Method for Twitter API
X.head = function head(url, f, b) {
  var xhr = new XMLHttpRequest
  var method = "HEAD"
  xhr.open(method, url, true)
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  xhr.addEventListener("load", X.onload.bind(xhr, method, url, "", f, b))
  xhr.addEventListener("error", X.onerror.bind(xhr, method, url, "", f, b))
  xhr.addEventListener("loadstart", X.onloadstart.bind(xhr, method, url, ""))
  xhr.addEventListener("loadend", X.onloadend.bind(xhr, method, url, ""))
  xhr.send(null)
  return xhr
}

# GET Method for Twitter API
X.get = function get(url, f, b) {
  var xhr = new XMLHttpRequest
  var method = "GET"
  url = T.fixURL(url)
  xhr.open(method, url, true)
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  var auth = X.getOAuthHeader(method, url, {})
  xhr.setRequestHeader("Authorization", auth)
  xhr.addEventListener("load", X.onload.bind(xhr, method, url, "", f, b))
  xhr.addEventListener("error", X.onerror.bind(xhr, method, url, "", f, b))
  xhr.addEventListener("loadstart", X.onloadstart.bind(xhr, method, url, ""))
  xhr.addEventListener("loadend", X.onloadend.bind(xhr, method, url, ""))
  xhr.send(null)
  return xhr
}

# POST Method for Twitter API
X.post = function post(url, q, f, b, c) {
  if (!c && !confirm("sure?\n" + url + "?" + O.stringify(q))) {
    return b && b(false)
  }
  var data, oaq, ctype = "application/x-www-form-urlencoded"
  var xhr = new XMLHttpRequest
  var method = "POST"
  xhr.open(method, url, true)
  if (q instanceof FormData) {
    data = q, oaq = {}, ctype = null
  } else if (typeof q is "object") {
    oaq = T.parseQuery(data = T.strQuery(q))
  } else {
    data = T.strQuery(oaq = T.parseQuery(q))
  }
  var auth = X.getOAuthHeader(method, url, oaq, url.oauthPhase)
  xhr.setRequestHeader("Authorization", auth)
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  if (ctype) xhr.setRequestHeader("Content-Type", ctype)
  xhr.addEventListener("load", X.onload.bind(xhr, method, url, q, f, b))
  xhr.addEventListener("error", X.onerror.bind(xhr, method, url, q, f, b))
  xhr.addEventListener("loadstart", X.onloadstart.bind(xhr, method, url, q))
  xhr.addEventListener("loadend", X.onloadend.bind(xhr, method, url, q))
  xhr.send(data)
  return xhr
}

# GET Method XDomain for Twitter API
X.getX = function get(url, f, b) {
  if (typeof GM_xmlhttpRequest is "function") {
    return GM_xmlhttpRequest({ method: "GET", url: url, onload: f })
  }
  var script = D.ce("script")
  for (var fn; window[fn = "f" + String(Math.random()).slice(2)];)
  script.src = url + "&callback=" + fn
  window[fn] = (data) -> {
    f({responseText:JSON.stringify(data)})
    delete window[fn]
    D.rm(script)
  }
  D.q("body").add(script)
}
