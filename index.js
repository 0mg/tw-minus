// index.js

var fs = require("fs");
var http = require("http");
var https = require("https");
var URL = require("url");
var crypto = require("crypto");
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
  forceHTTPS: function(req, res, err) {
    var header = new Header(".txt");
    header["location"] = L.TW_MINUS_URL + req.url;
    res.writeHead(302, header);
    res.write(header["location"]);
    res.end();
  },
  xhr: function(req, browser, rcvdata) {
    var callback = function(twres) {
      browser.writeHead(twres.statusCode, twres.headers);
      twres.on("data", function(d) { browser.write(d); });
      twres.on("end", function() { browser.end(); console.log("req end") });
    };
    var params = Object.create(req);
    params.data = rcvdata;
    sendTwitter(params, browser, callback);
  }
};
srvres.websocket = function(req, browser, rcvdata) {
  var callback = function(twres) {
    twres.on("data", function(d) {
      browser.write(WSF.framify(d));
    });
    twres.on("end", function() {
      browser.write(WSF.framify(JSON.stringify(twres.headers)));
      browser.write(WSF.framify(String(twres.statusCode)));
      browser.write(WSF.framify("", "binary"));
    });
  };
  var params = rcvdata;
  if (Object.prototype.toString.call(params) !== "[object Object]") return;
  params.url = String(params.url);
  params.data = String(params.data);
  params.headers = Object(params.headers);
  params.socket = browser;
  return sendTwitter(params, browser, callback).
    on("error", function() { browser.write(WSF.framify([1], "binary")); });
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
var sendTwitter = function(params, browser, callback) {
  var tokens = String(params.headers.authorization).split(",");
  if (tokens.length === 3) {
    params.oauth_phase = tokens[0];
    params.token = tokens[1];
    params.token_secret = tokens[2];
  }
  var url;
  if (params.url.indexOf(L.TW_STREAM_URL + "/") === 0) {
    url = params.url;
  } else {
    url = L.TW_API_URL + params.url;
  }
  var urlo = URL.parse(url, true);
  var postqry;
  if (params.headers["content-type"] === "application/x-www-form-urlencoded") {
    postqry = URL.parse("?" + params.data, true).query;
  } else {
    postqry = {};
  }
  var headers = {
    "x-forwarded-for": params.socket.remoteAddress
  };
  if ("accept-encoding" in params.headers) {
    headers["accept-encoding"] = params.headers["accept-encoding"];
  }
  if ("content-type" in params.headers) {
    headers["content-type"] = params.headers["content-type"];
  }
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
  var req = https.request(options, callback);
  req.on("error", function() {}); // MUST LISTEN
  req.on("close", function() { console.log("req close"); });
  req.write(params.data);
  req.end(); console.log("req open");
  return req;
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
  // Server <- browser new WebSocket(..)
  var WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
  var inkey = req.headers["sec-websocket-key"];
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
  skt.on("data", function(fm) {
    // Patch for Opera 12.17
    if (fm.length === 1) {
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
    if (params === undefined) return;
    reqTwing = srvres.websocket(req, skt, params);
  });
  skt.on("error", function() {}).
  on("timeout", function() { closeIO(reqTwing, skt); }).
  on("end", function() { closeIO(reqTwing, skt); }). // <- close tab, F5
  on("close", function() { closeIO(reqTwing, skt); }); // <- end(), event[error]
});
