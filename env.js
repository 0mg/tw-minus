// env.js

var F, L;

// Files in server .html .js
module.exports.F = F = {};
F.index_html_path = "./html/index.html";
F.fixURLtoFileName = function(path) {
  return "./html" + path.replace(/\/$/, "/index.html");
};
F.isRealFileName = function(filename) {
  return F.realfilenames.some(function(realname) {
    return filename === realname;
  });
};
F.realfilenames = [
  F.index_html_path,
  "./html/tw-minus.user.js",
  "./html/tw-minus-patch.js",
  "./html/favicon.ico"
];

// Location of tw-minus
module.exports.L = L = {};
L.twMinusIsOnWeb = "PORT" in process.env;
L.PORT = L.twMinusIsOnWeb ? process.env.PORT | 0 : 3000;
L.TW_MINUS_URL = process.env.URL || "http://localhost:" + L.PORT;
L.TW_API_URL = "https://api.twitter.com";
