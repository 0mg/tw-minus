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
    "accept-encoding": params.headers["accept-encoding"],
    "x-forwarded-for": params.socket.remoteAddress
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
    console.log("<- Tw res");
    var entry = new Buffer("");
    res.on("data", function(d) {
      var fixds = d.toString("utf-8").replace(/\r\n/g, "");
      entry = Buffer.concat([entry, d]);
      console.log("<- Tw Stream | " +
        fixds.slice(0,10) + "..." + fixds.slice(-10));
      if (res.statusCode !== 200) {
        browser.write(encodeWSFrame(new Buffer(JSON.stringify(res.headers))));
        browser.write(encodeWSFrame(d));
        return;
      }
      try {
        JSON.parse(entry.toString("utf-8"));
        browser.write(encodeWSFrame(entry));
        console.log("-> skt.write");
        entry = new Buffer("");
      } catch(e) {
        if (fixds.trim() === "") {
          browser.write(encodeWSFrame("."));
          console.log("-> skt.write.");
          entry = new Buffer("");
        }
      }
    });
    res.on("end", function() {
      browser.end();
    });
  });
  req.on("error", function() { console.log("reqTW error"); });
  req.on("close", function() { console.log("reqTW close"); });
  req.write(params.data);
  req.end();
  console.log("req -> Tw");
  return req;
};

// Server listen <- request from browser
var server = http.createServer();
server.listen(L.PORT);

// Server <-> WebSocket browser
server.on("upgrade", function(req, skt, head) {
  console.log("<<< new WebSocket");
  // destroy SOCKET & TWITTER STREAMING
  var stopWS = function(reqTwin, wsocke) {
    console.log("# stopWS");
    if (wsocke) {
      wsocke.end();
      wsocke = null;
      console.log("  skt.end() ->");
    }
    if (reqTwin) {
      reqTwin.abort();
      reqTwin = null;
      console.log("  reqTW.abort() ->");
    }
    console.log("  " + Date.now());
  };
  // Server <- browser new WebSocket(..)
  var reqTwing;
  var wsocket;
  stopWS(reqTwing, wsocket);
  var crypto = require("crypto");
  var magic = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
  var inkey = req.headers["sec-websocket-key"];
  var outkey = crypto.createHash("sha1").update(inkey + magic).digest("base64");
  var mes = [
    "HTTP/1.1 101 Switching Protocols",
    "Upgrade: websocket",
    "Connection: Upgrade",
    "Sec-WebSocket-Accept:" + outkey,
    ""
  ].join("\r\n") + "\r\n";
  skt.write(mes);
  console.log("WS open >>>");
  wsocket = skt;
  // listen <- browser websocket.send(..)
  skt.on("error", function() {
    console.log("skt error");
    stopWS(reqTwing, wsocket);
  });
  skt.on("timeout", function() {
    console.log("skt timeout");
    stopWS(reqTwing, wsocket);
  });
  skt.on("end", function() {
    console.log("skt end");
    stopWS(reqTwing, wsocket);
  });
  skt.on("close", function() {
    console.log("skt close ------------------------------------");
    stopWS(reqTwing, wsocket);
  });
  skt.on("data", function(fm) {
    console.log("<-- ws.send()");
    var wsfo = decodeWSFrame(fm);
    if (wsfo === 0) {
      stopWS(reqTwing, wsocket);
      return;
    } else if (!wsfo) {
      return;
    }
    // GO TWITTER STREAM
    var params = wsfo;
    params.method = "GET";
    params.data = "";
    var tokens = String(params.headers.authorization).split(",");
    if (tokens.length === 3) {
      params.oauth_phase = tokens[0];
      params.token = tokens[1];
      params.token_secret = tokens[2];
    }
    reqTwing = streamTwitter(params, skt);
  });
});

// WSFrame to Message
var decodeWSFrame = function(fm) {
  // Extract message from WSFrame
  var ib = 0;
  console.log("################## ", fm);

  // [BYTE 1]
  var b1 = fm[ib];
  if ((b1 & 0x0f) === 0x8) {
    console.log("<-- ws.close()");
    return 0;
  }
  ib++;

  // [BYTE 2]
  var b2 = fm[ib];
  var mask = !!(b2 >>> 7);
  var length = b2 & 0x7f;
  ib++;

  if (length === 126) {
    // [BYTE 3 4] 16bit = 2B
    length = fm.readUInt16BE(ib);
    ib += 2;
  } else if (length === 127) {
    // [BYTE 3 4 5 6 7 8 9 A] 64bit = 8B
    length = fm.readDoubleBE(ib);
    ib += 8;
  }

  // [BYTE (3<=*) * * *] 4B
  if (mask) {
    mask = fm.slice(ib, ib + 4);
    ib += 4;
  }

  // [BYTE (3<=*) ...] length B
  // UN-MASKING message
  var msg = fm.slice(ib);
  if (mask) for (var i = 0; i < length; ++i) msg[i] ^= mask[i % 4];

  try {
    return JSON.parse(msg.toString("utf-8"));
  } catch(e) {
    console.log("JSON cannot parse * of ws.send(*)");
    return false;
  }
};

// Message to WSFrame
var encodeWSFrame = function(msg) {
  msg = new Buffer(msg);
  // [BYTE 1]
  var b1 = new Buffer([1 << 7 | 0x1]);
  // [BYTE 2] [BYTE 3]
  var b2, b3;
  if (msg.length > 125) {
    b2 = new Buffer([126]);
    b3 = new Buffer([msg.length >>> 8, msg.length & 0xff])
  } else {
    b2 = new Buffer([msg.length]);
    b3 = new Buffer([]);
  }
  return Buffer.concat([b1, b2, b3, msg]);
};

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
