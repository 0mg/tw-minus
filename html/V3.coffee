# Render UI of account settings
V.main.settingAccount = (my) -> {
  var uname = D.ce("input")
  var unameBtn = D.ce("button").add(D.ct("Check"))
  var auto = D.ce("input").sa("type", "number").sa("min", "0").sa("value", "4")
  var autoBtn = D.ce("button").add(D.ct("Search"))
  var autoResult = D.ce("div")
  var xhrpool = []
  var autoSearching = false
  var api = "/i/users/username_available.json?username="
  function autoStart() {
    autoBtn.textContent = "Cancel"
    checkUnameAuto(+auto.value)
  }
  function autoFinish() {
    autoBtn.textContent = "Search"
    xhrpool.forEach((xhr) -> { xhr.abort(); })
    xhrpool = []
  }
  function checkUnameAuto(len) {
    D.empty(autoResult)
    for (var i = 0, max = 50; i <= max; ++i) {
      var src = "1234567890abcdefghijklmnopqrstuvwxyz_"
      var s = ""
      for (var j = len; j-- > 0;) s += src[Math.random() * 37 | 0]
      ((s, i, max) -> {
        var xhrobj = X.get(api + s, (xhr) -> {
          var data = JSON.parse(xhr.responseText)
          autoResult.add(D.ct(s + ":" + (data.valid && "#true#") + " "))
          if (i is max) autoFinish()
        }, null)
        xhrpool.push(xhrobj)
      })(s, i, max)
    }
  }
  function checkUname(unameValue) {
    X.get(api + unameValue, (xhr) -> {
      var main = D.q("#main")
      D.empty(main).add(O.htmlify(JSON.parse(xhr.responseText)))
    }, null)
  }
  unameBtn.addEventListener("click", -> checkUname(uname.value); })
  uname.addEventListener("keypress", (e) -> {
    if (e.keyCode is 13) D.ev(unameBtn, "click")
  })
  autoBtn.addEventListener("click", (e) -> {
    xhrpool.length ? autoFinish(): autoStart()
  })
  D.q("#subaction").add(uname, unameBtn)
  D.q("#side").add(
    D.ce("h3").add(D.ct("screen_name")),
    D.ct("length:"), auto, autoBtn, autoResult
  )
}

# Render UI for API testing
V.main.testAPI = (my) -> {
  var nd = {
    main: D.q("#main"),
    side: D.q("#side"),
    head: {
      url: D.ce("input").sa("size", "60"),
      send: D.ce("button").add(D.ct("HEAD"))
    },
    get: {
      url: D.ce("input").sa("size", "60"),
      send: D.ce("button").add(D.ct("GET"))
    },
    post: {
      url: D.ce("input").sa("size", "60"),
      send: D.ce("button").add(D.ct("POST"))
    },
    dst: D.ce("div"),
    header: D.ce("div")
  }
  var state = LS.state.load()
  nd.head.url.value = state["head_q"] || ""
  nd.get.url.value = state["get_q"] || ""
  nd.post.url.value = state["post_q"] || ""
  function printErase() { D.empty(nd.header); D.empty(nd.dst); }
  function printData(xhr) {
    printHead(xhr)
    printText(xhr)
  }
  function printHead(xhr) {
    var data = xhr.getAllResponseHeaders()
    var datanode = D.tweetize(data)
    nd.header.add(datanode)
  }
  function printText(xhr) {
    var data = xhr.responseText
    var datanode = D.ct(data)
    try {
      datanode = O.htmlify(JSON.parse(data))
    } catch(e) {
      datanode = O.htmlify(xhr.responseText)
    }
    nd.dst.add(datanode)
  }
  nd.head.send.addEventListener("click", ->
    LS.state.save("head_q", nd.head.url.value)
    printErase()
    X.head(nd.head.url.value, printData, printData)
  })
  nd.get.send.addEventListener("click", ->
    LS.state.save("get_q", nd.get.url.value)
    printErase()
    X.get(nd.get.url.value, printData, printData)
  })
  nd.post.send.addEventListener("click", ->
    var str = nd.post.url.value.split("?")
    var url = str[0]
    var q = str.slice(1).join("?")
    LS.state.save("post_q", nd.post.url.value)
    printErase()
    X.post(url, q, printData, printData, true)
  })
  nd.head.url.addEventListener("keypress", (e) -> {
    if (e.keyCode is 13) D.ev(nd.head.send, "click")
  })
  nd.get.url.addEventListener("keypress", (e) -> {
    if (e.keyCode is 13) D.ev(nd.get.send, "click")
  })
  nd.post.url.addEventListener("keypress", (e) -> {
    if (e.keyCode is 13) D.ev(nd.post.send, "click")
  })

  nd.main.add(
    D.ce("h3").add(D.ct(location.host)),
    D.ce("ul").add(
      D.ce("li").add(nd.head.url, nd.head.send),
      D.ce("li").add(nd.get.url, nd.get.send),
      D.ce("li").add(nd.post.url, nd.post.send)
    ),
    nd.dst
  )
  nd.side.add(nd.header)
}

# <html>API rate_limit_status</html>
V.main.showAPIStatus = (xhr) -> {
  var data = JSON.parse(xhr.responseText)
  var nd = {
    root: D.ce("table").sa("id", "api-status").add(D.ce("tr").add(
      D.ce("th").add(D.ct("API")),
      D.ce("th").add(D.ct("rest")),
      D.ce("th").add(D.ct("init")),
      D.ce("th").add(D.ct("reset"))
    ))
  }
  (function f(d) {
    Object.keys(d).forEach((key, i) -> {
      var p = d[key]
      if (typeof p is "object" && p isnt null) {
        if (key.indexOf("/") is 0) {
          var rem = p["remaining"], lim = p["limit"], res = p["reset"]
          var tr = D.ce("tr").add(
            D.ce("th").add(D.ct(key)),
            D.ce("td").add(D.ct(rem)),
            D.ce("td").add(D.ct(lim)),
            D.ce("td").add(D.ct(
              new Date(res * 1000).toLocaleTimeString()
            ))
          )
          if (rem isnt lim) tr.classList.add("active")
          nd.root.add(tr)
        } else f(p)
      }
    })
  })(data)
  D.q("#main").add(nd.root)
}

# Settings view to updating user profile
V.main.settingProfile = (my) -> {
  var nd = {
    icon: D.ce("input").sa("type", "file"),
    upload: D.ce("button").add(D.ct("Upload")),
    name: D.ce("input").sa("size", 60).sa("value", my.name || ""),
    url: D.ce("input").sa("size", 60).sa("value", my.url || ""),
    loc: D.ce("input").sa("size", 60).sa("value", my.location || ""),
    desc: D.ce("textarea").sa("cols", 60).sa("rows", 6).
      add(D.ct(my.description || "")),
    save: D.ce("button").add(D.ct("Update"))
  }
  var onScs = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    if (API.getType(data) is "user") {
      D.empty(D.q("#side")); D.empty(D.q("#main"))
      V.main.settingProfile(data)
    }
  }
  nd.save.addEventListener("click", ->
    API.updateProfile(
      nd.name.value, nd.url.value, nd.loc.value, nd.desc.value, onScs)
  })
  nd.upload.addEventListener("click", ->
    var file = nd.icon.files[0]
    if (file) API.uploadIcon(file, onScs)
  })
  V.outline.changeDesign(my)
  V.outline.rendProfileOutline(my)
  D.q("#main").add(
    D.ce("dl").add(
      D.ce("dt").add(D.ct("icon")), D.ce("dd").add(nd.icon),
      D.ce("dd").add(nd.upload)
    ),
    D.ce("dl").add(
      D.ce("dt").add(D.ct("name")), D.ce("dd").add(nd.name),
      D.ce("dt").add(D.ct("url")), D.ce("dd").add(nd.url),
      D.ce("dt").add(D.ct("location")), D.ce("dd").add(nd.loc),
      D.ce("dt").add(D.ct("description")), D.ce("dd").add(nd.desc),
      D.ce("dd").add(nd.save)
    )
  )
}

# Settings of this application
V.main.settingOptions = ->
  var lsdata = LS.load()
  var lstext = JSON.stringify(lsdata)
  var nd = {
    vwLS: {
      tree: O.htmlify(lsdata),
      raw: D.ce("textarea").sa("cols", 60).sa("rows", 10),
      save: D.ce("button").add(D.ct("SAVE"))
    }
  }
  nd.vwLS.raw.value = lstext
  nd.vwLS.save.addEventListener("click", ->
    if (confirm("sure?")) try {
      var lstextInput = nd.vwLS.raw.value
      var lsdataInput = JSON.parse(lstextInput)
      localStorage[LS.NS] = lstextInput
      D.empty(nd.vwLS.tree)
      nd.vwLS.tree.add(O.htmlify(lsdataInput))
    } catch(e) {
      alert(e)
    }
  })
  D.q("#main").add(
    D.ce("h3").add(D.ct("localStorage['" + LS.NS + "']")),
    nd.vwLS.raw, nd.vwLS.save, nd.vwLS.tree
  )
}
