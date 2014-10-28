// index.js

var fs = require("fs");
var http = require("http");
var https = require("https");
var URL = require("url");
var env = require("./env.js"),
    F = env.F, L = env.L;
var P = require("./P.js");

// make Response Header
var Header = function(filename) {
  var arr = String(filename).split(".");
  var ext, ctype;
  if (arr.length <= 1) {
    ext = "txt";
  } else {
    ext = arr[arr.length - 1].toLowerCase();
  }
  switch (ext) {
  case "html":
    ctype = "text/html; charset=utf-8";
    break;
  case "json":
    ctype = "application/json; charset=utf-8";
    break;
  case "js":
    ctype = "text/javascript; charset=utf-8";
    break;
  case "ico":
    ctype = "image/x-icon";
    //ctype = "image/vnd.microsoft.icon";
    break;
  case "txt":
    ctype = "text/plain; charset=utf-8";
    break;
  default:
    ctype = "text/plain; charset=utf-8";
    break;
  }
  return {
    "content-type": ctype,
    "x-content-type-options": "nosniff",
    "x-frame-options": "deny",
    "x-xss-protection": "1; mode=block",
    "strict-transport-security": "max-age=2592000"
  };
};

// Server Response -> to browser
var srvres = {
  main: function(req, res, data, filename) {
    var header = new Header(filename);
    header["cache-control"] = "private, max-age=900";
    header["content-length"] = data.length;
    res.writeHead(200, header);
    res.write(data);
    res.end();
  },
  404: function(req, res, data, filename, err) {
    res.writeHead(404, new Header(".txt"));
    res.write("file " + req.url + " is not exist");
    res.end();
  },
  goAuthorize: function(req, res) {
    var header = new Header(".txt");
    header["location"] = L.TW_API_URL + req.url;
    res.writeHead(302, header);
    res.write(header["location"]);
    res.end();
  },
  forceHTTPS: function(req, res, err) {
    var header = new Header(".txt");
    header["location"] = L.TW_MINUS_URL + req.url;
    res.writeHead(302, header);
    res.write(header["location"]);
    res.end();
  },
  xhr: function(req, res, rcvdata) {
    var params = Object.create(req);
    var tokens = String(params.headers.authorization).split(",");
    if (tokens.length === 3) {
      params.oauth_phase = tokens[0];
      params.token = tokens[1];
      params.token_secret = tokens[2];
    }
    if (!("content-type" in params.headers)) {
      params.headers["content-type"] = "";
    }
    params.data = rcvdata;
    sendTwitter(params, res);
  }
};

// Server call Twitter API -> response to browser
var sendTwitter = function(params, browser) {
  var url = L.TW_API_URL + params.url;
  var urlo = URL.parse(url, true);
  var postqry;
  if (params.headers["content-type"] === "application/x-www-form-urlencoded") {
    postqry = URL.parse("?" + params.data, true).query;
  } else {
    postqry = {};
  }
  var headers = {
    "accept-encoding": params.headers["accept-encoding"]
  };
  headers["content-type"] = params.headers["content-type"];
  headers["authorization"] = P.getOAuthHeader(
    params.method,
    url,
    postqry,
    params.oauth_phase,
    params.token,
    params.token_secret
  );
  var options = {
    host: urlo.host,
    path: params.url,
    method: params.method,
    headers: headers
  };
  var req = https.request(options, function(res) {
    browser.writeHead(res.statusCode, res.headers);
    res.on("data", function(d) {
      browser.write(d);
    });
    res.on("end", function() {
      browser.end();
    });
  });
  req.write(params.data);
  req.end();
};

// User streams
var streamTwitter = function(params, browser) {
  var url = "https://userstream.twitter.com" + params.url;
  var urlo = URL.parse(url, true);
  var postqry;
  if (params.headers["content-type"] === "application/x-www-form-urlencoded") {
    postqry = URL.parse("?" + params.data, true).query;
  } else {
    postqry = {};
  }
  var headers = {
    "accept-encoding": params.headers["accept-encoding"]
  };
  headers["content-type"] = params.headers["content-type"];
  headers["authorization"] = P.getOAuthHeader(
    params.method,
    url,
    postqry,
    params.oauth_phase,
    params.token,
    params.token_secret
  );
  var options = {
    host: urlo.host,
    path: params.url,
    method: params.method,
    headers: headers
  };
  var req = https.request(options, function(res) {
    browser.writeHead(res.statusCode, res.headers);
    res.on("data", function(d) {
      browser.write(d);
    });
    res.on("end", function() {
      browser.end();
    });
  });
  req.write(params.data);
  req.end();
};

// Server listen <- request from browser
var server = http.createServer();
server.listen(L.PORT);

// Server <- request from browser
server.on("request", function(req, res) {
  if (L.twMinusIsOnWeb && req.headers["x-forwarded-proto"] !== "https") {
    srvres.forceHTTPS(req, res, "");
    return;
  }
  var data = new Buffer("");
  var filename = F.fixURLtoFileName(req.url);
  if (F.isRealFileName(filename)) {
    // File request
    filename = filename;
  } else if (
    req.method !== "GET" ||
    req.headers["x-requested-with"] === "XMLHttpRequest"
  ) {
    // XHR request
    req.on("data", function(d) { data = Buffer.concat([data, d]); });
    req.on("end", function() { srvres.xhr(req, res, data); });
    return;
  } else if (/^\/oauth\/authorize($|\?)/.test(req.url)) {
    // Access to Special URL
    srvres.goAuthorize(req, res);
    return;
  } else if (/^\/1\.1\/user\.json($|\?)/.test(req.url)) {
    return;
  } else {
    // 404 Not Found
    filename = F.index_html_path;
  }
  fs.readFile(filename, function(err, data) {
    if (err) {
      srvres[404](req, res, data, filename, err);
    } else {
      srvres.main(req, res, data, filename);
    }
  });
});

// Server <-> WebSocket browser
server.on("upgrade", function(req, skt, head) {
  var crypto = require("crypto");
  var magic = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
  var inkey = req.headers["sec-websocket-key"];
  var outkey = crypto.createHash("sha1").update(inkey + magic).digest("base64");
  var mes = [
    "HTTP/1.1 101 WebSocket",
    "upgrade: websocket",
    "connection: upgrade",
    "sec-websocket-accept: " + outkey,
    ""
  ].join("\r\n") + "\r\n";
  skt.write(mes);
  skt.on("data", function(fm) {
    // EXTRACT MESSAGE from FRAME
    var idx = 1;
    var ml = fm[idx];
    //    1 1111111 | bit
    // Mask Length  | mean
    var masking = ml >>> 7;
    var mask = 0;
    var leng = ml & 0x7f;
    var length = 0;
    if (leng === 127) {
      // 64bit = 8B
      idx += 1;
      length = fm.readDoubleBE(idx);
      idx += 8;
    } else if (leng === 126) {
      // 16bit = 2B
      idx += 1;
      length = fm.readUInt16BE(idx);
      idx += 2;
    } else {
      // 7bit = (1B)
      length = fm[idx] & 0x7f;
      idx += 1;
    }
    if (masking) {
      // 4B
      mask = fm.slice(idx, idx + 4);
      idx += 4;
    }
    // UN-MASKING
    var mskmsg = fm.slice(idx);
    var msg = new Buffer(length);
    for (var i = 0; i < length; ++i) {
      msg[i] = mskmsg[i] ^ mask[i % 4];
    }
    console.log(msg.toString("utf-8"));
  });
});
