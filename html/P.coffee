# Cipher objects
P = {}

# HMAC SHA-1
P.bits = (str) ->
  # convert key to bit array
  var BYTE = 8
  var data = []
  for c in str.split("")
    code = c.charCodeAt 0
    bits = (((Array BYTE).join "0") + code.toString 2)[-BYTE...]
    data = [data..., P.bits.split ""]
  data

P.hmac = (hf) ->
  BLOCK_SIZE = hf.BLOCK_SIZE
  IPAD = 0x36
  OPAD = 0x5C
  pad = (p) ->
    BYTE = 8
    base = (Array(BYTE).join("0") + p.toString(2)).slice(-BYTE)
    (data) -> c ^ base[i % BYTE] for c, i in data
  (key, text) ->
    keybits = P.bits key
    if keybits.length > BLOCK_SIZE
      keybits = P.bits hf key
    if keybits.length < BLOCK_SIZE
      padSize = BLOCK_SIZE - keybits.length
      keybits.push 0 for [0..padSize]
    textbits = P.bits(text)
    ikpad = pad(IPAD)(keybits)
    okpad = pad(OPAD)(keybits)
    a = ikpad.concat(textbits)
    b = P.bits(hf(a))
    c = okpad.concat(b)
    d = hf(c)
P.sha1 = function sha1enc(key) {
  var BYTE = 8
  var ONE_PAD = [1, 0, 0, 0]
  var BLOCK_SIZE = sha1enc.BLOCK_SIZE
  var LENGTH_PAD_SIZE = 64
  # convert key to bit string
  var data = Array.isArray(key) ? key.slice(): P.bits(key)
  var keyLen = data.length
  # add "1" (4 bits)
  [].push.apply(data, ONE_PAD)
  # add padding "0" (? bits)
  var overflowSize = (data.length + LENGTH_PAD_SIZE) % BLOCK_SIZE
  var padSize = BLOCK_SIZE - overflowSize
  for (var i = 0; i < padSize; ++i) {
    data.push(0)
  }
  # add padding "length" (64 bits)
  var zeroes = Array(LENGTH_PAD_SIZE).join("0")
  var lengthPad = (zeroes + keyLen.toString(2)).slice(-LENGTH_PAD_SIZE)
  for (var i = 0; i < LENGTH_PAD_SIZE; ++i) {
    data.push(lengthPad[i] | 0)
  }
  # calc SHA1
  var hh = [
    0x67452301,
    0xEFCDAB89,
    0x98BADCFE,
    0x10325476,
    0xC3D2E1F0
  ]
  var blockLen = data.length / BLOCK_SIZE
  for (var i = 0; i < blockLen; ++i) {
    var blockIndex = i * BLOCK_SIZE
    var block = data.slice(blockIndex, blockIndex + BLOCK_SIZE)
    sha1enc.calc(block, hh)
  }
  var output = new String(hh.map((s) -> {
    return String.fromCharCode(
      s >>> BYTE * 3 & 0xff,
      s >>> BYTE * 2 & 0xff,
      s >>> BYTE * 1 & 0xff,
      s >>> BYTE * 0 & 0xff
    )
  }).join(""))
  output.text = hh.map((s) -> {
    return ("00000000" + (s >>> 0).toString(16)).slice(-8)
  }).join("")
  return output
}
Object.defineProperty(P.sha1, "BLOCK_SIZE", { value: 512 })
P.sha1.calc = function sha1calc(block, hh) {
  function getF(t) {
    return (0 <= t && t <= 19) ?
      function f00_19(b, c, d) {
        return (b & c) | ((~b) & d)
      }:
    (20 <= t && t <= 39) ?
      function f20_39(b, c, d) {
        return b ^ c ^ d
      }:
    (40 <= t && t <= 59) ?
      function f40_59(b, c, d) {
        return (b & c) | (b & d) | (c & d)
      }:
    (60 <= t && t <= 79) ?
      function f60_79(b, c, d) {
        return b ^ c ^ d
      }:
    undefined
  }
  function getK(t) {
    return ( 0 <= t && t <= 19) ? 0x5A827999:
           (20 <= t && t <= 39) ? 0x6ED9EBA1:
           (40 <= t && t <= 59) ? 0x8F1BBCDC:
           (60 <= t && t <= 79) ? 0xCA62C1D6:
                                  undefined
  }
  function shift(n) {
    return (X) -> {
      return (X << n) | (X >>> 32-n)
    }
  }
  var SECTOR_SIZE = 32
  var W = Array(80)
  for (var t = 0; t < 16; ++t) {
    var start = t * SECTOR_SIZE
    var end = start + SECTOR_SIZE
    var sector = block.slice(start, end)
    var sectorData = parseInt(sector.join(""), 2)
    W[t] = sectorData
  }
  for (var t = 16; t < W.length; ++t) {
    W[t] = shift(1)(W[t-3] ^ W[t-8] ^ W[t-14] ^ W[t-16])
  }
  var a = hh[0]
  var b = hh[1]
  var c = hh[2]
  var d = hh[3]
  var e = hh[4]
  var temp
  for (var t = 0; t < 80; ++t) {
    temp = shift(5)(a) + getF(t)(b, c, d) + e + W[t] + getK(t)
    e = d
    d = c
    c = shift(30)(b)
    b = a
    a = temp
  }
  hh[0] += a
  hh[1] += b
  hh[2] += c
  hh[3] += d
  hh[4] += e
}

# OAuth
P.oauth = {}
P.oauth.consumer_key = "e5uRPFBMQJcwfbEcPnwiw"
P.oauth.consumer_secret = ""
P.oauth.sha = (sha_text, sha_key) -> {
  #return new jsSHA(sha_text,"TEXT").getHMAC(sha_key,"TEXT","SHA-1","B64")
  return btoa(P.hmac(P.sha1)(sha_key, sha_text))
}
P.oauth.enc = function enc(s) {
  var chr = /[\ud800-\udbff][\udc00-\udfff]|[\S\s]/g
  return String(s).replace(chr, (c) -> {
    var e = {
      "!": "%21",
      "'": "%27",
      "(": "%28",
      ")": "%29",
      "*": "%2A"
    }
    return e[c] || encodeURIComponent(c)
  })
}
P.oauth.genSig = (->
  var enc = P.oauth.enc
  function genShaKey(secret1, secret2) {
    return enc(secret1) + "&" + enc(secret2)
  }
  function genShaText(method, url, oadata, qobj) {
    var s = [], i
    for (i in oadata) {
      s.push([enc(i), enc(oadata[i])])
    }
    for (i in qobj) {
      [].concat(qobj[i]).forEach((val) -> {
        s.push([enc(i), enc(val)])
      })
    }
    var urlParts = url.match(/([^?#]*)[?]?([^#]*)/)
    var baseURL = urlParts[1]
    var search = urlParts[2]
    if (search) {
      var qrys = T.parseQuery(search)
      for (i in qrys) {
        [].concat(qrys[i]).forEach((val) -> {
          s.push([enc(i), enc(val)])
        })
      }
    }
    s.sort()
    var text =
      enc(method) + "&" +
      enc(baseURL) + "&" +
      enc(s.map((arr) -> {
        return arr[0] + "=" + arr[1]
      }).join("&"))
    return text
  }
  function genSig(method, url, data, q, secret1, secret2) {
    var sha_key = genShaKey(secret1, secret2)
    var sha_text = genShaText(method, url, data, q)
    var sig = P.oauth.sha(sha_text, sha_key)
    return sig
  }
  return genSig
})()
