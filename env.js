// env.js

var F, L;

// Files in server .html .js
module.exports.F = F = {};
F.index_html_path = "./html/index.html";
F.fixURLtoFileName = function(path) {
  return "./html" + path.replace(/\/$/, "/index.html");
};
F.realfilenames = [
  F.index_html_path,
  "./html/tw-minus.user.js",
  "./html/tw-minus-patch.js",
  "./html/tw-minus-heroku.js",
  "./html/favicon.ico"
];

// Location of this app
module.exports.L = L = {};
L.thisAppIsOnWeb = "PORT" in process.env;
L.PORT = L.thisAppIsOnWeb ? process.env.PORT | 0 : 3000;
L.THIS_APP_URL = process.env.URL || "http://localhost:" + L.PORT;
L.TW_API_URL = "https://api.twitter.com";
L.TW_STREAM_URL = "https://userstream.twitter.com";
