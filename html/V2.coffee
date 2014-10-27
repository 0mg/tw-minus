# Render view of list of settings
V.main.newSettings = (my) -> {
  var root = U.ROOT + "settings/"
  var nd = {
    api: D.ce("a").sa("href", root + "api").add(D.ct("API")),
    aps: D.ce("a").sa("href", root + "api/status").add(D.ct("API Status")),
    aco: D.ce("a").sa("href", root + "account").add(D.ct("Account")),
    pro: D.ce("a").sa("href", root + "profile").add(D.ct("Profile")),
    dez: D.ce("a").sa("href", root + "design").add(D.ct("Design")),
    fw: D.ce("a").sa("href", root + "follow").add(D.ct("Follow")),
    opt: D.ce("a").sa("href", root + "options").add(D.ct("Options"))
  }
  return D.ce("ul").add(
    D.ce("li").add(nd.api),
    D.ce("li").add(nd.aps),
    D.ce("li").add(nd.aco),
    D.ce("li").add(nd.pro),
    D.ce("li").add(nd.dez),
    D.ce("li").add(nd.fw),
    D.ce("li").add(nd.opt)
  )
}

# Render view of list of users
V.main.newUsers = (my) -> {
  var root = U.ROOT + "users/"
  var nd = {
    blo: D.ce("a").sa("href", root + "blocking").add(D.ct("Blocking")),
    mut: D.ce("a").sa("href", root + "muting").add(D.ct("Muting"))
  }
  return D.ce("ul").add(
    D.ce("li").add(nd.blo),
    D.ce("li").add(nd.mut)
  )
}

# Login UI
V.main.showLoginUI = (qs) -> {
  var getReqToken = ->
    var url = API.urls.oauth.request()()
    X.post(url, "", ongetReqToken, onErr)
    nd.errvw.textContent = ""
  }
  var ongetReqToken = (xhr) -> {
    var tokens = T.parseQuery(xhr.responseText)
    LS.save("request_token", tokens["oauth_token"])
    LS.save("request_token_secret", tokens["oauth_token_secret"])
    var url = API.urls.oauth.authorize()()
    var request_token = tokens["oauth_token"]
    location.href = url + "?oauth_token=" + request_token
  }
  var getAcsToken = ->
    var tokens = T.parseQuery(qs)
    var verifier = tokens["oauth_verifier"]
    var q = "oauth_verifier=" + verifier
    var url = API.urls.oauth.access()()
    X.post(url, q, ongetAcsToken, onErr)
    nd.errvw.textContent = ""
  }
  var ongetAcsToken = (xhr) -> {
    var tokens = T.parseQuery(xhr.responseText)
    LS.save("access_token", tokens["oauth_token"])
    LS.save("access_token_secret", tokens["oauth_token_secret"])
    LS.clear("request_token")
    LS.clear("request_token_secret")
    var my = {
      id_str: tokens["user_id"],
      screen_name: tokens["screen_name"]
    }
    LS.save("credentials", my)
    D.empty(D.q("#globalbar")).add(V.panel.newGlobalBar(my))
    V.panel.updTweetBox(my)
    D.q("#main").add(O.htmlify(tokens))
  }
  var onErr = (xhr) -> {
    if (!xhr) return
    nd.errvw.textContent = xhr.responseText || xhr.getAllResponseHeaders()
  }
  var nd = {
    errvw: D.ce("dd"),
    login: D.ce("button").add(D.ct("Get Request token")),
    verify: D.ce("button").add(D.ct("Get Access token"))
  }
  nd.login.addEventListener("click", getReqToken)
  nd.verify.addEventListener("click", getAcsToken)
  if (qs) D.q("#main").add(
    D.ce("dl").add(
      D.ce("dt").add(D.ct("Login (STEP 2 of 2)")),
      D.ce("dd").add(nd.verify),
      nd.errvw
    )
  )
  else D.q("#main").add(
    D.ce("dl").add(
      D.ce("dt").add(D.ct("Login (STEP 1 of 2)")),
      D.ce("dd").add(nd.login),
      nd.errvw
    )
  )
}

# Render View of Colors Setting
V.main.customizeDesign = (my) -> {
  # {colors/bgimage model}
  var color = JSON.parse(JSON.stringify(my))

  # opened image file
  var imgfile = { file: null, dataURL: null }

  # form nodes
  var fm = {
    form: D.ce("dl"),
    bg: {
      upnew: O.sa(D.ce("input").sa("type", "checkbox"), { disabled: true }),
      file: D.ce("input").sa("type", "file"),
      use: D.ce("input").sa("type", "checkbox"),
      tile: D.ce("input").sa("type", "checkbox"),
      color: D.ce("input"),
      update: D.ce("button").add(D.ct("Update"))
    },
    textColor: D.ce("input"),
    linkColor: D.ce("input"),
    sidebar: {
      fillColor: D.ce("input"),
      borderColor: D.ce("input")
    },
    update: D.ce("button").add(D.ct("Update"))
  }

  # set current <input>.values
  fm.bg.tile.checked = color.profile_background_tile
  fm.bg.use.checked = color.profile_use_background_image
  fm.bg.color.value = color.profile_background_color
  fm.textColor.value = color.profile_text_color
  fm.linkColor.value = color.profile_link_color
  fm.sidebar.fillColor.value = color.profile_sidebar_fill_color
  fm.sidebar.borderColor.value = color.profile_sidebar_border_color

  # add event listeners
  fm.form.addEventListener("input", (event) -> {
    var input = event.target
    if (input.value.length isnt 6 || isNaN("0x" + input.value)) return
    switch (input) {
    case fm.bg.color: color.profile_background_color = input.value; break
    case fm.textColor: color.profile_text_color = input.value; break
    case fm.linkColor: color.profile_link_color = input.value; break
    case fm.sidebar.fillColor:
      color.profile_sidebar_fill_color = input.value
      break
    case fm.sidebar.borderColor:
      color.profile_sidebar_border_color = input.value
      break
    }
    V.outline.changeDesign(color)
  })
  fm.bg.upnew.addEventListener("change", (e) -> {
    color.profile_background_image_url = e.target.checked ?
      imgfile.dataURL : my.profile_background_image_url
    V.outline.changeDesign(color)
  })
  fm.bg.file.addEventListener("change", ->
    var file = fm.bg.file.files[0]
    imgfile.file = file
    fm.bg.upnew.disabled = false
    fm.bg.upnew.checked = true
    fm.bg.use.checked = true
    var fr = new FileReader
    fr.addEventListener("load", ->
      imgfile.dataURL = "data:" + file.type + ";base64," + btoa(fr.result)
      color.profile_background_image_url = imgfile.dataURL
      color.profile_use_background_image = true
      V.outline.changeDesign(color)
    })
    fr.readAsBinaryString(file)
  })
  fm.bg.use.addEventListener("change", (e) -> {
    color.profile_use_background_image = e.target.checked
    V.outline.changeDesign(color)
  })
  fm.bg.tile.addEventListener("change", (e) -> {
    color.profile_background_tile = e.target.checked
    V.outline.changeDesign(color)
  })
  fm.bg.update.addEventListener("click", ->
    API.updateProfileBgImage(
      color.profile_use_background_image && fm.bg.upnew.checked ?
        imgfile.file : undefined,
      color.profile_use_background_image,
      color.profile_background_tile, null
    )
  })
  fm.update.addEventListener("click", ->
    API.updateProfileColors(
      fm.bg.color.value,
      fm.textColor.value,
      fm.linkColor.value,
      fm.sidebar.fillColor.value,
      fm.sidebar.borderColor.value
    )
  })

  # render form nodes
  D.q("#main").ins(fm.form.add(
    D.ce("dt").add(D.ct("background image")),
    D.ce("dd").add(
      D.ce("label").add(fm.bg.upnew, D.ct("upload"), fm.bg.file)
    ),
    D.ce("dd").add(
      D.ce("label").add(fm.bg.use, D.ct("use image"))
    ),
    D.ce("dd").add(
      D.ce("label").add(fm.bg.tile, D.ct("tile"))
    ),
    D.ce("dd").add(fm.bg.update),
    D.ce("dt").add(D.ct("background color")),
    D.ce("dd").add(fm.bg.color),
    D.ce("dt").add(D.ct("text color")),
    D.ce("dd").add(fm.textColor),
    D.ce("dt").add(D.ct("link color")),
    D.ce("dd").add(fm.linkColor),
    D.ce("dt").add(D.ct("sidebar color")),
    D.ce("dd").add(fm.sidebar.fillColor),
    D.ce("dt").add(D.ct("sidebar border color")),
    D.ce("dd").add(fm.sidebar.borderColor),
    D.ce("dd").add(fm.update)
  ))

  # render current colors/bgimage
  V.outline.rendProfileOutline(my, my, 2)
  V.outline.changeDesign(my)
  if (my.status) {
    var tweet = {user:my}; for (var i in my.status) tweet[i] = my.status[i]
    delete tweet.retweeted_status
    V.main.rendTL([tweet], my)
  }
}
