# CONST VALUE
C = {}
C.APP_NAME = "tw-minus"

# Local Storage
LS = {}
LS.NS = C.APP_NAME
LS.STRUCT =
  "consumer_key": ""
  "consumer_secret": ""
  "request_token": ""
  "request_token_secret": ""
  "access_token": ""
  "access_token_secret": ""
  "credentials": {}
  "credentials_modified": 0
  "mylists": []
  "mylists_modified": 0
  "saved_searches": []
  "saved_searches_modified": 0
  "configuration": {}
  "configuration_modified": 0
LS.reset = ->
  localStorage[LS.NS] = JSON.stringify LS.STRUCT
  LS.STRUCT
LS.save = (name, value) ->
  data = LS.load()
  if typeof data isnt "object" then return data
  if name of LS.STRUCT
    data[name] = value
    localStorage[LS.NS] = JSON.stringify data
    return data
  else
    return false
LS.clear = (name) ->
  LS.save name, LS.STRUCT[name]
LS.put = (data) ->
  for i of data then LS.save i, data[i]
LS.load = ->
  text = localStorage[LS.NS]
  if LS.NS not of localStorage then return LS.reset()
  try
    data = JSON.parse text
    if typeof data is "object" then throw data
  catch e
    msg = "localStorage['#{LS.NS}'] is broken.\nreset?"
    if prompt msg, text then return LS.reset()
    else return text
  for i of LS.STRUCT
    if i not of data then data[i] = LS.STRUCT[i]
  for i of data
    invalid = []
    if i not of LS.STRUCT
      invalid.push i + ":" + data[i]
      delete data[i]
  localStorage[LS.NS] = JSON.stringify data
  if invalid.length then alert "deleted from LS\n" + invalid.join "\n"
  return data

# history.state
LS.state = {}
LS.state.save = (name, value) ->
  state = JSON.parse history.state || "{}"
  state[name] = value
  history.replaceState JSON.stringify state, document.title, location.href
  state

LS.state.load = ->
  JSON.parse history.state || "{}"
