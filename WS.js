// WS.js
var WS_parent, WSF;
WS_parent = function() {
  // some WebSocket handler
};
WSF = function(frame) { "use strict"; // new WSF(<buffer>)
  var opts = WSF.parse(frame);
  var opcode = opts.opcode, rawdata = opts.rawdata;
  var data_type = WSF.DATA_TYPES[opcode] || opcode;
  var data = data_type === "text" ? rawdata.toString("utf-8") : rawdata;
  var json = undefined;
  if (data_type === "text") try { json = JSON.parse(data); } catch(e) {}
  this.type = data_type;
  this.data = data;
  this.json = json;
};
WSF.framify = function(data, type) { // opts={type:"DATA_TYPES",data:"*"}
  var opts = { type: type || "text", data: data };
  return WSF.prototype.toFrame.call(opts);
};
WSF.prototype.toFrame = function() {
  var opcode = [].indexOf.call(WSF.DATA_TYPES, this.type);
  var rawdata = Buffer.from(this.data);
  // [BYTE 1]
  var b1 = Buffer.from([1 << 7 | opcode]);
  // [BYTE 2] [BYTE 3]
  var b2, b3;
  if (rawdata.length > 125) {
    b2 = Buffer.from([126]);
    b3 = Buffer.from([rawdata.length >>> 8, rawdata.length & 0xff])
  } else {
    b2 = Buffer.from([rawdata.length]);
    b3 = Buffer.from([]);
  }
  return Buffer.concat([b1, b2, b3, rawdata]);
};
WSF.DATA_TYPES = {
  0x1: "text",
  0x2: "binary",
  0x8: "close",
  0x9: "ping",
  0xa: "pong"
};
WSF.DATA_TYPES.length = 0x10; // array-like object
WSF.parse = function(frame) {
  // decode frame of WebSocket send(*)
  var fm = Buffer.from(frame);
  var ib = 0;
  var b1 = fm[ib]; // [BYTE 1]
  ib++;
  var b2 = fm[ib]; // [BYTE 2]
  var mask = !!(b2 >>> 7);
  var length = b2 & 0x7f;
  ib++;
  if (length === 126) { // [BYTE 3 4] 16bit = 2B
    length = fm.readUInt16BE(ib);
    ib += 2;
  }
  if (mask) { // [BYTE (3<=*) * * *] 4B
    mask = fm.slice(ib, ib + 4);
    ib += 4;
  }
  // [BYTE (3<=*) ...] length B | UN-MASKING message
  var rawdata = fm.slice(ib);
  if (mask) for (var i = 0; i < length; ++i) rawdata[i] ^= mask[i % 4];
  return {
    opcode: b1 & 0xf,
    mask: mask,
    length: length,
    rawdata: rawdata
  };
};
WS_parent.WSF = WSF;
module.exports = WS_parent;
