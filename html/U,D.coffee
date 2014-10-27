# URL CONST VALUE and Functions

U = {}
U.ROOT = "/robots.txt?-=/"
U.Q = "&"
U.getURL = ->
  var location_pathname = location.pathname.replace(/#/g, "%23")
  var pathall =
    (location_pathname + location.search).substring(U.ROOT.length).split(U.Q)
  var path = pathall[0]
  var query = T.parseQuery(pathall.slice(1).join("&"))
  return {
    path: path,
    query: query
  }
}

# DOM Functions
D = function D(e) {
  if (e) e.add = D.add, e.ins = D.ins, e.sa = D.sa, e.q = D.q, e.qs = D.qs
  return e
}
D.add = function add() {
  for (var i = 0; i < arguments.length; ++i) this.appendChild(arguments[i])
  return this
}
D.ins = function ins() {
  for (var i = 0; i < arguments.length; ++i) {
    this.insertBefore(arguments[i], this.firstChild)
  }
  return this
}
D.sa = function sa() { this.setAttribute.apply(this, arguments); return this; }
D.q = (s) -> { return D((this is D ? document: this).querySelector(s)); }
D.qs = (s) -> {
  return (this is D ? document: this).querySelectorAll(s)
}
D.ce = (s) -> {
  return D(document.createElementNS("http://www.w3.org/1999/xhtml", s))
}
D.ct = (s) -> { return document.createTextNode(s); }
D.cf = -> return D(document.createDocumentFragment()); }
D.rm = (e) -> { return e && e.parentNode.removeChild(e); }
D.empty = (e) -> {
  while (e.hasChildNodes()) e.removeChild(e.lastChild); return e
}
D.ev = (e, s) -> {
  var v = document.createEvent("Event")
  v.initEvent(s, true, true)
  e.dispatchEvent(v)
  return e
}
D.HTML_ENTITIES = {
  nbsp: 160, iexcl: 161, cent: 162, pound: 163, curren: 164, yen: 165,
  brvbar: 166, sect: 167, uml: 168, copy: 169, ordf: 170, laquo: 171, not: 172,
  shy: 173, reg: 174, macr: 175, deg: 176, plusmn: 177, sup2: 178, sup3: 179,
  acute: 180, micro: 181, para: 182, middot: 183, cedil: 184, sup1: 185,
  ordm: 186, raquo: 187, frac14: 188, frac12: 189, frac34: 190, iquest: 191,
  Agrave: 192, Aacute: 193, Acirc: 194, Atilde: 195, Auml: 196, Aring: 197,
  AElig: 198, Ccedil: 199, Egrave: 200, Eacute: 201, Ecirc: 202, Euml: 203,
  Igrave: 204, Iacute: 205, Icirc: 206, Iuml: 207, ETH: 208, Ntilde: 209,
  Ograve: 210, Oacute: 211, Ocirc: 212, Otilde: 213, Ouml: 214, times: 215,
  Oslash: 216, Ugrave: 217, Uacute: 218, Ucirc: 219, Uuml: 220, Yacute: 221,
  THORN: 222, szlig: 223, agrave: 224, aacute: 225, acirc: 226, atilde: 227,
  auml: 228, aring: 229, aelig: 230, ccedil: 231, egrave: 232, eacute: 233,
  ecirc: 234, euml: 235, igrave: 236, iacute: 237, icirc: 238, iuml: 239,
  eth: 240, ntilde: 241, ograve: 242, oacute: 243, ocirc: 244, otilde: 245,
  ouml: 246, divide: 247, oslash: 248, ugrave: 249, uacute: 250, ucirc: 251,
  uuml: 252, yacute: 253, thorn: 254, yuml: 255, fnof: 402, Alpha: 913,
  Beta: 914, Gamma: 915, Delta: 916, Epsilon: 917, Zeta: 918, Eta: 919,
  Theta: 920, Iota: 921, Kappa: 922, Lambda: 923, Mu: 924, Nu: 925, Xi: 926,
  Omicron: 927, Pi: 928, Rho: 929, Sigma: 931, Tau: 932, Upsilon: 933, Phi: 934,
  Chi: 935, Psi: 936, Omega: 937, alpha: 945, beta: 946, gamma: 947, delta: 948,
  epsilon: 949, zeta: 950, eta: 951, theta: 952, iota: 953, kappa: 954,
  lambda: 955, mu: 956, nu: 957, xi: 958, omicron: 959, pi: 960, rho: 961,
  sigmaf: 962, sigma: 963, tau: 964, upsilon: 965, phi: 966, chi: 967, psi: 968,
  omega: 969, thetasym: 977, upsih: 978, piv: 982, bull: 8226, hellip: 8230,
  prime: 8242, Prime: 8243, oline: 8254, frasl: 8260, weierp: 8472, image: 8465,
  real: 8476, trade: 8482, alefsym: 8501, larr: 8592, uarr: 8593, rarr: 8594,
  darr: 8595, harr: 8596, crarr: 8629, lArr: 8656, uArr: 8657, rArr: 8658,
  dArr: 8659, hArr: 8660, forall: 8704, part: 8706, exist: 8707, empty: 8709,
  nabla: 8711, isin: 8712, notin: 8713, ni: 8715, prod: 8719, sum: 8721,
  minus: 8722, lowast: 8727, radic: 8730, prop: 8733, infin: 8734, ang: 8736,
  and: 8743, or: 8744, cap: 8745, cup: 8746, int: 8747, there4: 8756, sim: 8764,
  cong: 8773, asymp: 8776, ne: 8800, equiv: 8801, le: 8804, ge: 8805, sub: 8834,
  sup: 8835, nsub: 8836, sube: 8838, supe: 8839, oplus: 8853, otimes: 8855,
  perp: 8869, sdot: 8901, lceil: 8968, rceil: 8969, lfloor: 8970, rfloor: 8971,
  lang: 9001, rang: 9002, loz: 9674, spades: 9824, clubs: 9827, hearts: 9829,
  diams: 9830, quot: 34, amp: 38, apos: 39, lt: 60, gt: 62, OElig: 338,
  oelig: 339, Scaron: 352, scaron: 353, Yuml: 376, circ: 710, tilde: 732,
  ensp: 8194, emsp: 8195, thinsp: 8201, zwnj: 8204, zwj: 8205, lrm: 8206,
  rlm: 8207, ndash: 8211, mdash: 8212, lsquo: 8216, rsquo: 8217, sbquo: 8218,
  ldquo: 8220, rdquo: 8221, bdquo: 8222, dagger: 8224, Dagger: 8225,
  permil: 8240, lsaquo: 8249, rsaquo: 8250, euro: 8364
}
# eg. 'http://t.co' to '<a href="http://t.co">http://t.co</a>'
D.tweetize = (innerText, entities, exties) -> {
  var str, ctx = innerText || "", fragment = D.cf()
  if (entities) {
    entities = {
      # clone or []
      urls: [].concat(entities.urls || []),
      hashtags: [].concat(entities.hashtags || []),
      user_mentions: [].concat(entities.user_mentions || []),
      media: [].concat(exties ? exties.media : entities.media || [])
    }
    D.tweetize.all(ctx, entities, fragment, 0)
  } else while (ctx.length) {
    str = D.tweetize.one(ctx, fragment)
    ctx = ctx.substring(str.length)
  }
  fragment.normalize()
  return fragment
}
D.tweetize.TWRE = {
  httpurl: /^https?:\/\/\S+/,
  url: /^(?:javascript|data|about|opera):\S+/,
  mention: /^@\w+(?:\/[a-zA-Z](?:-?[a-zA-Z0-9])*)?/,
  hashTag: /^#\w*[a-zA-Z_]\w*/,
  crlf: /^(?:\r\n|\r|\n)/,
  entity: /^&(?:[a-zA-Z]+|#\d+|#x[\da-fA-F]+);/,
  supchar: /^(?:[\ud800-\udbff][\udc00-\udfff])+/,
  text: /^[^hjdao@#\r\n&\ud800-\udfff]+/
}
D.tweetize.all = function callee(ctx, entities, fragment, i) {
  if (!ctx) return fragment
  var str, url
  var eUrl = entities.urls[0], eHsh = entities.hashtags[0]
  var eMns = entities.user_mentions[0], eMed = entities.media[0]
  if (eUrl && eUrl.indices[0] is i) {
    str = ctx.substring(0, eUrl.indices[1] - i)
    fragment.add(D.tweetize.url(str, eUrl.expanded_url))
    entities.urls.shift()

  } else if (eHsh && eHsh.indices[0] is i) {
    str = ctx.substring(0, eHsh.indices[1] - i)
    fragment.add(D.tweetize.hashtag(str))
    entities.hashtags.shift()

  } else if (eMns && eMns.indices[0] is i) {
    str = ctx.substring(0, eMns.indices[1] - i)
    fragment.add(D.tweetize.mention(str))
    entities.user_mentions.shift()

  } else if (eMed && eMed.indices[0] is i) {
    str = ctx.substring(0, eMed.indices[1] - i)
    var list = D.ce("ul").sa("class", "twimgs")
    do {
      url = eMed.media_url_https + ":large"
      list.add(D.ce("li").add(D.ce("a").sa("href", url).
        add(D.ct(url.match(/[^/]+$/)))))
      entities.media.shift()
    } while (eMed = entities.media[0])
    fragment.add(list)

  } else str = D.tweetize.one(ctx, fragment)
  return callee(ctx.substring(str.length), entities, fragment,
    i + str.match(/[\ud800-\udbff][\udc00-\udfff]|[\S\s]/g).length)
}
D.tweetize.one = (ctx, fragment) -> {
  var TWRE = D.tweetize.TWRE
  var str, url, hash, uname, supchar
  if (str = TWRE.text.exec(ctx)) {
    str = str[0]; fragment.add(D.ct(str))

  } else if (str = TWRE.crlf.exec(ctx)) {
    str = str[0]; fragment.add(D.ce("br"))

  } else if (str = TWRE.entity.exec(ctx)) {
    str = str[0]; fragment.add(D.ct(T.decodeHTML(str)))

  } else if (str = TWRE.httpurl.exec(ctx)) {
    str = str[0]; fragment.add(D.tweetize.url(str))

  } else if (str = TWRE.hashTag.exec(ctx)) {
    str = str[0]; fragment.add(D.tweetize.hashtag(str))

  } else if (str = TWRE.mention.exec(ctx)) {
    str = str[0]; fragment.add(D.tweetize.mention(str))

  } else if (str = TWRE.supchar.exec(ctx)) {
    #str = str[0]; fragment.add(D.tweetize.emoji(str)); return str
    str = str[0]; fragment.add(
      D.ce("span").sa("class", "supchar").add(D.ct(str))
    )

  /*} else if (str = TWRE.url.exec(ctx)) {
    str = str[0]; url = str
    fragment.add(D.ce("a").sa("href", url).add(D.ct(url)));/**/

  } else {
    str = ctx.substring(0, 1); fragment.add(D.ct(str))
  }
  return str
}
D.tweetize.url = (url, expanded_url) -> {
  var a = D.ce("a").sa("href", url).add(D.ct(url))
  if (expanded_url) {
    a.href = expanded_url
    a.textContent = expanded_url
    a.classList.add("expanded_tco_url")
  }
  if (a.href.indexOf("#") is -1 && a.href.indexOf("?") is -1) {
    a.classList.add("maybe_shorten_url")
  }
  return a
}
D.tweetize.hashtag = (hash) -> {
  return D.ce("a").sa("href",
    U.ROOT + "search/" + P.oauth.enc(hash)
  ).add(D.ct(hash))
}
D.tweetize.mention = (mention) -> {
  var username = mention.substring(1)
  return D.cf().add(
    D.ct("@"), D.ce("a").sa("href", U.ROOT + username).add(D.ct(username))
  )
}
D.tweetize.emoji = (str) -> {
  var df = D.cf()
  var chars = str.match(/[\ud800-\udbff][\udc00-\udfff]/g)
  chars.forEach((chr) -> {
    var dir = "https://abs.twimg.com/emoji/v1/72x72/"
    var name = T.supchar.decode(chr).toString(16)
    var ext = ".png"
    var img = D.ce("img").sa("src", dir + name + ext).
      sa("alt", chr).sa("class", "emoji")
    img.addEventListener("error", ->
      var alt = D.ce("span").sa("class", "supchar").add(D.ct(chr))
      img.parentNode.replaceChild(alt, img)
    })
    df.add(img)
  })
  return df
}
