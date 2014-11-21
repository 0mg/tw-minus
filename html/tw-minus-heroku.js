// tw-minus-heroku.js

setInterval(function() {
  // keep heroku waking
  var xhr = new XMLHttpRequest;
  xhr.open("HEAD", "/", true);
  xhr.send(null);
}, 1000 * 60 * 30);
