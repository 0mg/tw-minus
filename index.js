// index.js

var fs = require("fs");
var http = require("http");
var https = require("https");
var URL = require("url");
var env = require("./env.js"),
    F = env.F, L = env.L;
var P = require("./P.js");
var WS = require("./WS.js"),
    WSF = WS.WSF;

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

// destroy Request outgoing & User Socket
var closeIO = function(server_req, user_socket) {
  if (server_req) {
    server_req.abort(); // -> event [close]
  }
  if (user_socket) {
    user_socket.end(); // -> event [close]
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
    var entry = new Buffer("");
    res.on("data", function(d) {
      var fixds = d.toString("utf-8");
      entry = Buffer.concat([entry, d]);
      console.log("<- Tw Stream | " +
        fixds.slice(0,10) + "..." + fixds.slice(-10));
      if (res.statusCode !== 200) {
        browser.write(WSF.framify(JSON.stringify(res.headers)));
        browser.write(WSF.framify(d));
        return;
      }
      var json = null;
      try { json = JSON.parse(entry.toString("utf-8")); } catch(e) {}
      if (json) {
        browser.write(WSF.framify(entry));
        console.log("-> skt.write");
        entry = new Buffer("");
      } else if (fixds.trim() === "") {
        browser.write(WSF.framify("."));
        console.log("-> skt.write.");
        entry = new Buffer("");
      }
    });
    res.on("end", function() {
      browser.end();
    });
  });
  req.on("error", function() {}); // MUST LISTEN
  req.on("close", function() { console.log("req close __|"); });
  req.write(params.data);
  req.end();
  return req;
};

// Server listen <- request from browser
var server = http.createServer();
server.listen(L.PORT);

// Server <-> WebSocket browser
server.on("upgrade", function(req, skt, head) {
  // Server <- browser new WebSocket(..)
  var WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
  var inkey = req.headers["sec-websocket-key"];
  var crypto = require("crypto");
  var outkey = crypto.createHash("sha1").
    update(inkey + WS_GUID).digest("base64");
  var outheader = [
    "HTTP/1.1 101 Switching Protocols",
    "Upgrade: websocket",
    "Connection: Upgrade",
    "Sec-WebSocket-Accept:" + outkey,
    ""
  ].join("\r\n") + "\r\n";
  // Server -> browser>authorize
  skt.write(outheader);
  // listen <- browser websocket.send(..)
  var reqTwing;
  var operafm = "";
  skt.on("error", function() {
  }).on("timeout", function() {
    closeIO(reqTwing, skt);
  }).on("end", function() { // <- browser close tab, F5
    closeIO(reqTwing, skt);
  }).on("close", function() { // <- end(), event[error]
    closeIO(reqTwing, null);
    console.log("skt close __/");
  });
  skt.on("data", function(fm) {
    console.log("<-- ws.send()");
    // Patch for Opera 12.17
    if (fm.length === 1 && (fm[0] & 0xf) <= 2) {
      operafm = new Buffer(fm);
      return;
    } else if (operafm.length) {
      fm = Buffer.concat([operafm, fm])
      operafm = "";
    }
    // DECODE * of ws.send(*)
    var wsfo = new WSF(fm);
    if (wsfo.type === "close") {
      closeIO(reqTwing, skt);
      return;
    }
    var params = wsfo.json;
    if (!params) return;
    // GO TWITTER STREAM
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
