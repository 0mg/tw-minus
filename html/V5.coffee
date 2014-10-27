V.misc = {}

V.misc.showCursorIds = (data) -> {
  var cur = {
    sor: D.cf(),
    next: D.ce("a").sa("class", "cursor_next"),
    prev: D.ce("a").sa("class", "cursor_prev")
  }
  var curl = U.getURL(), qrys = curl.query
  if ("previous_cursor_str" in data && data.previous_cursor_str isnt "0") {
    O.sa(qrys, { cursor: data.previous_cursor_str, index: data.prev_index })
    cur.prev.href = U.ROOT + curl.path + U.Q + T.strQuery(qrys)
    cur.sor.add(D.ce("li").add(cur.prev.add(D.ct("prev"))))
  }
  if ("next_cursor_str" in data && data.next_cursor_str isnt "0") {
    O.sa(qrys, { cursor: data.next_cursor_str, index: data.next_index })
    cur.next.href = U.ROOT + curl.path + U.Q + T.strQuery(qrys)
    cur.sor.add(D.ce("li").add(cur.next.add(D.ct("next"))))
  }
  cur.next.addEventListener("click", V.misc.onClickCursorIds)
  cur.prev.addEventListener("click", V.misc.onClickCursorIds)
  D.q("#cursor").add(cur.sor)
}

V.misc.onClickCursorIds = (e) -> {
  var state = LS.state.load()
  var qrys = T.fixURL(e.target.href).query
  if (qrys["cursor"] isnt state.ids_object["cursor"]) return
  e.preventDefault()
  D.empty(D.q("#main")); D.empty(D.q("#cursor")); D.q("body").scrollIntoView()
  history.pushState("", "", e.target.href)
  V.main.showUsersByLookup(
    state.ids_data,
    T.fixURL(state.ids_url).base + "?" + T.strQuery(qrys),
    state.ids_my, state.ids_mode
  )
}

V.main.cursorIdsPopState = (e) -> {
  var state = LS.state.load()
  V.main.rendUsers(state.ids_object, state.ids_my, state.ids_mode)
  if ("scrollTop" in state) D.q("body").scrollTop = state["scrollTop"]
}

# Step to Render View of list of users (following/ers, lists members.,)
V.main.showUsers = (url, my, mode) -> {
  var onScs = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    V.main.rendUsers(data, my, mode)
    LS.state.save("users_object", data)
  }
  X.get(url, onScs, V.misc.showXHRError)
  if (!(mode & 8)) { mode |= 8; V.panel.showUserManager(my); }
  LS.state.save("users_url", url)
  LS.state.save("users_my", my)
  LS.state.save("users_mode", mode)
}

V.misc.showCursor = (data) -> {
  var cur = {
    sor: D.cf(),
    next: D.ce("a").add(D.ct("next")),
    prev: D.ce("a").add(D.ct("prev"))
  }
  var curl = U.getURL(), qrys = curl.query
  if ("previous_cursor_str" in data && data.previous_cursor_str isnt "0") {
    qrys["cursor"] = data.previous_cursor_str
    cur.prev.href = U.ROOT + curl.path + U.Q + T.strQuery(qrys)
    cur.sor.add(D.ce("li").add(cur.prev))
  }
  if ("next_cursor_str" in data && data.next_cursor_str isnt "0") {
    qrys["cursor"] = data.next_cursor_str
    cur.next.href = U.ROOT + curl.path + U.Q + T.strQuery(qrys)
    cur.sor.add(D.ce("li").add(cur.next))
  }
  cur.next.addEventListener("click", V.misc.onClickCursor)
  cur.prev.addEventListener("click", V.misc.onClickCursor)
  D.q("#cursor").add(cur.sor)
}

V.misc.onClickCursor = (e) -> {
  var state = LS.state.load(), url, my, mode
  var sender =
    "users_url" in state ? V.main.showUsers:
    "lists_url" in state ? V.main.showLists: undefined
  if (sender is V.main.showUsers) {
    url = state.users_url, my = state.users_my, mode = state.users_mode
  } else if (sender is V.main.showLists) {
    url = state.lists_url, my = state.lists_my
  }
  var urlpts = T.fixURL(url)
  var newurl = urlpts.base + "?" + T.strQuery(O.sa(urlpts.query, {
    cursor: T.fixURL(e.target.href).query["cursor"]
  }))
  e.preventDefault()
  D.empty(D.q("#cursor")); D.empty(D.q("#main")); D.q("body").scrollIntoView()
  history.pushState("", "", e.target.href)
  sender(newurl, my, mode)
}

V.main.cursorPopState = (e) -> {
  var state = LS.state.load()
  V.main.rendUsers(state.users_object, state.users_my, state.users_mode)
  if ("scrollTop" in state) D.q("body").scrollTop = state["scrollTop"]
}

# Render View of list of lists
V.main.showLists = (url, my) -> {
  var re = url.match(/[?&]screen_name=(\w+)/)
  var oname = re ? re[1]: my.screen_name
  var onGet = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    if (!data.lists) data = {lists:data}; # format {cursor:0,lists[]}
    V.main.rendLists(data, oname)
    LS.state.save("lists_object", data)
  }
  X.get(url, onGet, V.misc.showXHRError)
  addEventListener("scroll", V.main.onScroll)
  addEventListener("popstate", V.main.cursorListsPopState)
  LS.state.save("lists_url", url)
  LS.state.save("lists_my", my)
  LS.state.save("lists_oname", oname)
}

V.main.rendLists = function rendLists(data, oname) {
  var root = D.cf()
  var lists = D.ce("ul")
  var subs = D.ce("ul")
  lists.className = subs.className = "listslist"
  lists.classList.add("own")
  if (!data.lists) data = {lists:data}; # format {cursor:0,lists[]}
  data.lists.forEach((l) -> {
    var target = l.user.screen_name is oname ? lists: subs
    target.add(rendLists.one(l))
  })
  D.empty(D.q("#cursor"))
  D.empty(D.q("#main"))
  root.add(
    lists.hasChildNodes() ? lists : D.cf(),
    subs.hasChildNodes() ? subs : D.cf()
  )
  D.q("#main").add(
    data.lists.length ? root: O.htmlify({Empty:"No Lists found"})
  )
  V.misc.showCursor(data)
}

V.main.cursorListsPopState = (e) -> {
  var state = LS.state.load()
  V.main.rendLists(state.lists_object, state.lists_oname)
  if ("scrollTop" in state) D.q("body").scrollTop = state["scrollTop"]
}

V.main.rendLists.one = (list) -> {
  var nd = {
    root: D.ce("li").sa("class", "list"),
    full_name: D.ce("a").add(D.ct(list.full_name.substring(1))).
      sa("href", U.ROOT + list.full_name.substring(1)).
      sa("class", "full_name"),
    icon: D.ce("img").sa("src", list.user.profile_image_url_https).
      sa("alt", list.user.screen_name).
      sa("class", "user-icon"),
    name: D.ce("span").add(D.ct(list.name)).
      sa("class", "name"),
    desc: D.ce("p").add(D.tweetize(list.description)).
      sa("class", "description"),
    meta: D.ce("div").sa("class", "meta"),
    date: D.ce("time").sa("class", "created_at").
      add(D.ct(T.gapTime(new Date(list.created_at))))
  }
  if (list.mode is "private") nd.root.classList.add("private")
  nd.root.add(nd.full_name, nd.icon, nd.name, nd.desc,
    nd.meta.add(nd.date))
  return nd.root
}

# Step to Render View of Timeline
V.main.showTL = (url, my) -> {
  function onScs(xhr) {
    var timeline = JSON.parse(xhr.responseText)
    if (timeline.statuses) timeline = timeline.statuses; # search 1.1
    LS.state.save("timeline_data", timeline)
    V.main.prendTL([].concat(timeline), my)
  }
  LS.state.save("timeline_url", url)
  LS.state.save("timeline_my", my)
  X.get(url, onScs, V.misc.showXHRError)
}

V.main.prendTL = (timeline, my, expurls) -> {
  V.main.rendTL(timeline, my)
  V.misc.expandUrls(D.q("#timeline"), expurls)
}

# Render View of Timeline (of home, mentions, messages, lists.,)
V.main.rendTL = function rendTL(timeline, my) {
  var tl_element = D.ce("ol").sa("id", "timeline")
  timeline.forEach((tweet) -> {
    tl_element.add(V.main.newTweet(tweet, my))
  })
  D.rm(D.q("#timeline"))
  D.q("#main").add(tl_element)
  if (!timeline.length) {
    return tl_element.add(O.htmlify({"Empty": "No tweets found"}))
  }
  # show cursor
  var curl = U.getURL()
  var max_id = T.decrement(timeline[timeline.length - 1].id_str)
  var past = D.ce("a").sa("href", U.ROOT + curl.path + U.Q + T.strQuery(
    O.sa(curl.query, { max_id: max_id })
  )).sa("class", "cursor_next").add(D.ct("past"))
  D.empty(D.q("#cursor")).add(D.ce("li").add(past))
  # ajaxize cursor
  past.addEventListener("click", (e) -> {
    var url = T.fixURL(LS.state.load()["timeline_url"])
    var pasturl = url.base + "?" +
      T.strQuery(O.sa(url.query, { max_id: max_id }))
    e.preventDefault()
    D.rm(D.q("#timeline")); D.empty(D.q("#cursor"))
    D.q("body").scrollIntoView()
    history.pushState("", "", e.target.href)
    V.main.showTL(pasturl, my)
  })
  addEventListener("popstate", V.main.onPopState)
  addEventListener("scroll", V.main.onScroll)
}

# modify [url's state]
V.main.onScroll = ->
  LS.state.save("scrollTop", D.q("body").scrollTop)
}

# load [url's state]
V.main.onPopState = (e) -> {
  var state = LS.state.load()
  V.main.prendTL([].concat(state["timeline_data"]),
    state["timeline_my"], state["expanded_urls"])
  if ("scrollTop" in state) D.q("body").scrollTop = state["scrollTop"]
}
