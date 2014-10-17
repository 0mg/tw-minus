// P.js

var crypto = require("crypto");
var URL = require("url");
var env = require("./env.js"),
    F = env.F, L = env.L;
var P;

// Cipher objects
module.exports = P = {};

// OAuth
P.oauth = {};
P.oauth.sha = function(sha_text, sha_key) {
  return crypto.createHmac("sha1", sha_key).update(sha_text).digest("base64");
};
P.oauth.enc = function enc(s) {
  var chr = /[\ud800-\udbff][\udc00-\udfff]|[\S\s]/g;
  return String(s).replace(chr, function(c) {
    var e = {
      "!": "%21",
      "'": "%27",
      "(": "%28",
      ")": "%29",
      "*": "%2A"
    };
    return e[c] || encodeURIComponent(c);
  });
};
P.oauth.genSig = (function() {
  var enc = P.oauth.enc;
  function genShaKey(secret1, secret2) {
    return enc(secret1) + "&" + enc(secret2);
  }
  function genShaText(method, url, oadata, qobj) {
    var s = [], i;
    for (i in oadata) {
      s.push([enc(i), enc(oadata[i])]);
    }
    for (i in qobj) {
      [].concat(qobj[i]).forEach(function(val) {
        s.push([enc(i), enc(val)]);
      });
    }
    var urlParts = url.match(/([^?#]*)[?]?([^#]*)/);
    var baseURL = urlParts[1];
    var search = urlParts[2];
    if (search) {
      var qrys = URL.parse("?" + search, true).query;
      for (i in qrys) {
        [].concat(qrys[i]).forEach(function(val) {
          s.push([enc(i), enc(val)]);
        });
      }
    }
    s.sort();
    var text =
      enc(method) + "&" +
      enc(baseURL) + "&" +
      enc(s.map(function(arr) {
        return arr[0] + "=" + arr[1];
      }).join("&"));
    return text;
  }
  function genSig(method, url, data, q, secret1, secret2) {
    var sha_key = genShaKey(secret1, secret2);
    var sha_text = genShaText(method, url, data, q);
    var sig = P.oauth.sha(sha_text, sha_key);
    return sig;
  }
  return genSig;
})();
// make OAuth "Authorization:" Header
P.getOAuthHeader = function(method, url, q, oauthPhase, token, token_secret) {
  var consumer_key = String(process.env.consumer_key);
  var consumer_secret = String(process.env.consumer_secret);
  var oauth_token_secret;
  var oadata = {
    "oauth_consumer_key": consumer_key,
    "oauth_nonce": Math.random().toString(36),
    "oauth_signature_method": "HMAC-SHA1",
    "oauth_timestamp": (Date.now() / 1000).toFixed(0),
    "oauth_version": "1.0"
  };
  switch (oauthPhase) {
  case "get_request_token":
    oauth_token_secret = "";
    oadata["oauth_callback"] = L.TW_MINUS_URL + "/login";
    break;
  case "get_access_token":
    oauth_token_secret = token_secret;
    oadata["oauth_token"] = token;
    break;
  default:
    oauth_token_secret = token_secret;
    oadata["oauth_token"] = token;
    break;
  }
  oadata["oauth_signature"] =
    P.oauth.genSig(
      method, url, oadata, q, consumer_secret, oauth_token_secret);
  var heads = [];
  for (var i in oadata) {
    heads.push(P.oauth.enc(i) + "=\"" + P.oauth.enc(oadata[i]) + "\"");
  }
  var header = "OAuth " + heads.join(",");
  return header;
};
