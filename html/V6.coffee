V.main.newTweet = (tweet_org, my) -> {
  var tweet = JSON.parse(JSON.stringify(tweet_org))

  # type tweet, RT or DM
  var twtype = API.getType(tweet)
  var isDM = twtype is "dmsg", isRT = twtype is "rt"

  # override props in JSON
  if (isDM) tweet.user = tweet.sender
  else if (isRT) tweet = tweet.retweeted_status

  # entry nodes
  var nd = {
    root: D.ce("li").sa("class", "tweet"),
    name: D.ce("a").
      sa("class", "screen_name").
      sa("href", U.ROOT + tweet.user.screen_name).
      add(D.ct(tweet.user.screen_name)),
    nick: D.ce("span").
      sa("class", "name").
      add(D.ct(T.decodeHTML(tweet.user.name))),
    icon: D.ce("img").
      sa("class", "user-icon").
      sa("alt", tweet.user.screen_name).
      sa("src", tweet.user.profile_image_url_https),
    reid: D.ce("a").
      sa("class", "in_reply_to"),
    text: D.ce("p").
      sa("class", "text").
      add(D.tweetize(tweet.text, tweet.entities, tweet.extended_entities)),
    meta: D.ce("div").
      sa("class", "meta"),
    date: D.ce("a").
      sa("class", "created_at").
      add(D.ct(T.gapTime(new Date(tweet.created_at)))),
    src: D.ce("a").sa("class", "source"),
    geo: D.ce("a").sa("class", "geo"),
    rter: D.ce("a").sa("class", "retweeter")
  }

  # entry
  nd.root.classList.add("screen_name-" + tweet.user.screen_name)
  nd.root.classList.add("id-" + tweet.id_str)
  if (tweet.user.protected) nd.root.classList.add("protected")
  if (tweet.user.verified) nd.root.classList.add("verified")
  if (isRT) nd.root.classList.add("retweet")
  if (/[RQ]T:?\s*@\w+/.test(tweet.text)) nd.root.classList.add("quote")
  nd.root.add(
    nd.name,
    nd.icon,
    nd.nick,
    nd.reid,
    nd.text,
    nd.meta.add(nd.date, nd.src, nd.geo, nd.rter),
    V.panel.makeTwAct(tweet_org, my)
  )

  # in reply to *
  if (tweet.in_reply_to_status_id_str) {
    nd.reid.sa("href", U.ROOT + tweet.in_reply_to_screen_name +
      "/status/" + tweet.in_reply_to_status_id_str)
    nd.reid.add(D.ct("in reply to " + tweet.in_reply_to_screen_name))
  } else if (isDM) {
    nd.reid.sa("href", U.ROOT + tweet.recipient_screen_name)
    nd.reid.add(D.ct("d " + tweet.recipient_screen_name))
  }

  # created_at
  nd.date.sa("href", isDM ?
    U.ROOT + "direct_messages/" + tweet.id_str:
    "https://twitter.com/" + tweet.user.screen_name + "/status/" + tweet.id_str
  )

  # source
  if (tweet.source) {
    var src = tweet.source.match(/<a href="([^"]*)"[^>]*>([^<]*)<\/a>/)
    if (src) {
      nd.src.sa("href", src[1]).add(D.ct(T.decodeHTML(src[2])))
    } else {
      nd.src.add(D.ct(T.decodeHTML(tweet.source)))
    }
  }

  # geo location
  if (tweet.place && tweet.place.name && tweet.place.country) {
    nd.geo.add(D.ct(tweet.place.name))
    nd.geo.sa("href", "https://maps.google.com/?q=" +
      (tweet.geo && tweet.geo.coordinates || tweet.place.full_name))
  }

  # RT by
  if (isRT) {
    nd.rter.sa("href", U.ROOT + tweet_org.user.screen_name).
      add(D.ct(tweet_org.user.screen_name))
  }

  return nd.root
}

# users search cursor
V.misc.showCursorPage = (data) -> {
  var cur = {
    sor: D.cf(),
    next: D.ce("a").sa("class", "cursor_next"),
    prev: D.ce("a").sa("class", "cursor_prev")
  }
  var curl = U.getURL(), qrys = curl.query
  var cpage = +[].concat(qrys["page"])[0] || 1
  if (cpage > 1) {
    cur.prev.href = U.ROOT + curl.path + U.Q + "page=" + (cpage - 1)
    cur.prev.add(D.ct("prev"))
    cur.sor.add(D.ce("li").add(cur.prev))
  }
  cur.next.href = U.ROOT + curl.path + U.Q + "page=" + (cpage + 1)
  cur.next.add(D.ct("next"))
  cur.sor.add(D.ce("li").add(cur.next))
  D.q("#cursor").add(cur.sor)
}

# show xhr state tip
V.misc.onXHRStart = (method, url, q) -> {
  var loading = D.ce("li").sa("class", "xhr-state").add(D.ct("loading.."))
  loading.classList.add("loading")
  D.q("#xhr-statuses").add(loading)
  setTimeout(-> D.rm(loading); }, 1000)
  return loading
}
V.misc.onXHREnd = (success, xhr, method, url, q) -> {
  var s = D.q(".xhr-state.loading")
  if (!s) s = V.misc.onXHRStart(method, url, q)
  s.classList.remove("loading")
  s.classList.add("done")
  if (success) {
    s.hidden = method isnt "POST"
    s.classList.add("success")
    s.textContent = "Success!"
  } else {
    s.classList.add("failed")
    s.textContent = "Failed(" + xhr.status + ")" +
      " " + method + " " + url + (q ? "?" + q: "")
  }
}

# show login link if 401
V.misc.showXHRError = (xhr, to) -> {
  var data; try { data = JSON.parse(xhr.responseText); }
  catch(e) { data = { error: xhr.getAllResponseHeaders() }; }
  if (!to) to = D.q("#main")
  switch (xhr.status) {
  case 400: case 401:
    to.add(D.ce("a").sa("href", U.ROOT + "login").add(D.ct("login")))
    break
  }
  to.add(O.htmlify(data))
}

# Scripts after render page
V.misc.expandUrls = (parent, expurls) -> {
  return
  var onScs = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    LS.state.save("expanded_urls", data)
    expand(data)
  }
  var expand = (data) -> {
    [].forEach.call(anchors, (a, i) -> {
      var exp_url = data[a.href]
      if (exp_url) {
        a.classList.add("expanded_url")
        a.classList.remove("maybe_shorten_url")
        a.href = a.textContent = decodeURIComponent(escape(exp_url))
      }
    })
  }
  var anchors = D.qs.call(parent, "a.maybe_shorten_url")
  var urls = [].map.call(anchors, (a) -> { return a.href; })
  if (urls.length) {
    if (expurls) expand(expurls)
    else API.resolveURL(urls, onScs, null)
  }
}

# Make Action buttons panel
V.panel = {}

# ON/OFF Button Constructor
V.Button = (labelDefault, labelOn) -> {
  this.name = name
  this.labelDefault = labelDefault
  this.labelOn = labelOn isnt undefined ? labelOn: labelDefault
  this.node = D.ce("button").add(D.ct(labelDefault)).
    sa("role", "button").sa("aria-pressed", false)
}
V.Button.prototype = {
  on: false,
  turn: (flag) -> {
    if (typeof flag is "boolean") {
      this.on = flag
      this.node.sa("aria-pressed", flag)
      this.node.textContent = flag ? this.labelOn: this.labelDefault
    } else {
      this.on = undefined
      this.node.sa("aria-pressed", "mixed")
      this.node.textContent = this.labelDefault
    }
    return this
  },
  enable: -> this.node.disabled = false; return this; },
  disable: -> this.node.disabled = true; return this; },
  show: -> this.node.hidden = false; return this; },
  hide: -> this.node.hidden = true; return this; }
}

# Buttons to do Follow Request Accept/Deny
V.panel.makeReqDecider = (user) -> {
  var ad = {
    node: D.ce("div"),
    accept: D.ce("button").add(D.ct("Accept")),
    deny: D.ce("button").add(D.ct("Deny"))
  }
  function onDecide() { D.rm(ad.node.parentNode); }
  ad.accept.addEventListener("click", ->
    API.acceptFollow(user.screen_name, onDecide)
  })
  ad.deny.addEventListener("click", ->
    API.denyFollow(user.screen_name, onDecide)
  })
  ad.node.add(ad.accept, ad.deny)
  return ad.node
}

# Action buttons panel for fav, reply, retweet
V.panel.makeTwAct = (tweet_org, my) -> {
  var tweet = JSON.parse(JSON.stringify(tweet_org))

  # JSON type
  var tweet_type = API.getType(tweet)
  var isDM = tweet_type is "dmsg"
  var isRT = tweet_type is "rt"
  var isTW = tweet_type is "tweet"

  # override props in JSON
  if (isRT) tweet = tweet.retweeted_status

  # more JSON types (supply)
  var isMyTweet = isTW && tweet.user.id_str is my.id_str
  var isMyRT = isRT && tweet_org.user.id_str is my.id_str
  var isRTtoMe = isRT && tweet.user.id_str is my.id_str
  var isAnyRTedByMe = "current_user_retweet" in tweet_org

  # buttons nodes
  var ab = {
    node: D.ce("div"),
    fav: new V.Button("Fav", "Unfav"),
    rep: new V.Button("Reply"),
    del: new V.Button("Delete"),
    rt: new V.Button("RT", "UnRT")
  }
  ab.rep.node.sa("class", "reply")
  if (isTW || isRT) ab.node.add(ab.fav.node)
  ab.node.add(ab.rep.node)
  if (isDM || isMyTweet || isRTtoMe) ab.node.add(ab.del.node)
  else ab.node.add(ab.rt.node)

  # init
  if (tweet.favorited) ab.fav.turn(true)
  if (isMyRT || isAnyRTedByMe) ab.rt.turn(true)

  # test
  /*ab.node.add(
    D.ct(isRT ? "This is a RT by " + tweet_org.user.screen_name + ". ":
                "This is a Tweet. "),
    D.ct(
      isMyRT ? "So, by you.":
      isRTtoMe ? "It's RT to YOU":
      isAnyRTedByMe ? "You RTed it.":
      ""
    )
  );/**/

  # add event listeners

  # [Fav] btn
  ab.fav.node.addEventListener("click", ->
    ab.fav.on ?
      API.unfav(tweet.id_str, -> ab.fav.turn(false); }):
      API.fav(tweet.id_str, -> ab.fav.turn(true); })
  })

  # [Reply] btn
  ab.rep.node.addEventListener("click", isDM ? ->
    # main
    var status = D.q("#status")
    status.value = "d " + tweet.sender.screen_name + " " + status.value
    # outline
    D.ev(status, "input").focus()
  }: (ev) -> {
    var status = D.q("#status"), repid = D.q("#in_reply_to_status_id")
    var repname = D.q("#in_reply_to_screen_name")
    var tgt = ev.ctrlKey ? tweet_org: tweet
    # main
    if (repid.value isnt tgt.id_str) {
      status.value = "@" + tgt.user.screen_name + " " + status.value
      repid.value = tgt.id_str
      repname.value = tgt.user.screen_name
    } else {
      repid.value = ""
      repname.value = ""
    }
    # outline
    D.ev(status, "input").focus()
  })

  # [RT] btn
  ab.rt.node.addEventListener("click", ->
    # undo RT (button on my RT)
    if (isMyRT) API.untweet(tweet_org.id_str, ->
      ab.rt.turn(false)
      D.rm(D.q(".tweet.id-" + tweet.id_str))
    })
    # undo RT (button on owner tweet or others' RT)
    else if (isAnyRTedByMe) API.untweet(
      tweet_org.current_user_retweet.id_str,
      ->
        isAnyRTedByMe = false
        ab.rt.turn(false)
      }
    )
    # do RT
    else API.retweet(tweet.id_str, (xhr) -> {
      var data = JSON.parse(xhr.responseText)
      tweet_org.current_user_retweet = { id_str: data.id_str }
      isAnyRTedByMe = true
      ab.rt.turn(true)
    })
  })

  # [Delete] btn
  ab.del.node.addEventListener("click", isDM ? ->
    API.deleteMessage(tweet.id_str,
      -> D.rm(D.q(".tweet.id-" + tweet.id_str)); })
  }: (isMyTweet || isRTtoMe) ? ->
    API.untweet(tweet.id_str,
      -> D.rm(D.q(".tweet.id-" + tweet.id_str)); })
  }: undefined)

  return ab.node
}
