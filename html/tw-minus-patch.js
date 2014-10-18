// tw-minus-patch.js

(function() {
  // property reserver
  var def = function(object, name, value) {
    Object.defineProperty(object, name, {
      get: function() { return value },
      set: function() {}
    });
  };

  // Reserve U
  def(window, "U", {});
  def(U, "ROOT", "/");
  def(U, "Q", "?");

  // Reserve X
  def(window, "X", {});
  def(X, "getOAuthHeader", function(method, url, q, oauthPhase) {
    var lsdata = LS.load();
    var oauth_token;
    var oauth_token_secret;
    switch (oauthPhase) {
    case "get_request_token":
      oauth_token = "";
      oauth_token_secret = "";
      break;
    case "get_access_token":
      oauth_token = lsdata["request_token"];
      oauth_token_secret = lsdata["request_token_secret"];
      break;
    default:
      oauth_token = lsdata["access_token"];
      oauth_token_secret = lsdata["access_token_secret"];
      break;
    }
    var heads = [];
    heads.push(oauthPhase);
    heads.push(oauth_token);
    heads.push(oauth_token_secret);
    var header = heads.join(",");
    return header;
  });

  // for IE11
  if (!("readAsBinaryString" in FileReader.prototype)) {
    FileReader.prototype.readAsBinaryString = function(file) {
      var that = this;
      var fr = new FileReader;
      fr.addEventListener("load", function() {
        for (var buf = "", i = 0; i < fr.result.byteLength; ++i) {
          buf += String.fromCharCode(new Uint8Array(fr.result)[i]);
        }
        Object.defineProperty(that, "result",
          { get: function() { return buf; } });
        var load = document.createEvent("Event");
        load.initEvent("load", false, false);
        that.dispatchEvent(load);
      });
      fr.readAsArrayBuffer(file);
    };
  }
})();
