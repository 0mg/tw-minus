# tw-minus-patch.js

# property reserver
def = (object, name, value) ->
  Object.defineProperty object, name,
    get: -> value
    set: ->

# Reserve U
def window, "U", {}
def U, "ROOT", "/"
def U, "Q", "?"

# Reserve X
def window, "X", {}
def X, "getOAuthHeader", (method, url, q, oauth_phase) ->
  lsdata = LS.load()
  switch oauth_phase
    when "get_request_token" then [
      oauth_phase
      ""
      ""
    ]
    when "get_access_token" then [
      oauth_phase
      lsdata["request_token"]
      lsdata["request_token_secret"]
    ]
    else [
      oauth_phase
      lsdata["access_token"]
      lsdata["access_token_secret"]
    ]

# for IE11
if "readAsBinaryString" not of FileReader.prototype
  FileReader.prototype.readAsBinaryString = (file) ->
    that = this
    fr = new FileReader
    fr.addEventListener "load", ->
      buf = ""
      for i in [0..fr.result.byteLength]
        buf += String.fromCharCode (new Uint8Array fr.result)[i]
      Object.defineProperty that, "result", get: -> buf
      load = document.createEvent "Event"
      load.initEvent "load", no, no
      that.dispatchEvent load
    fr.readAsArrayBuffer file

if not +new Date "Tue Mar 21 20:50:14 +0000 2006"
  Dative = Date
  Date = (args...) ->
    a0 = args[0]
    if @constructor isnt Date
      return Dative.apply null, args

    if args.length is 1 and typeof a0 is "string" and
    /^\w{3} \w{3} \d\d \d\d:\d\d:\d\d \+\d{4} \d+$/.test a0
      args[0] = a0[-4..] + a0[0..-5]

    F = Function.prototype.bind.apply Dative, [undefined, args...]
    F.prototype = Dative.prototype
    new F

  for key in Object.getOwnPropertyNames Dative
    Date[key] = Dative[key] if key isnt "prototype"
