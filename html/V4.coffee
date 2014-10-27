# Render UI of following settings
V.main.settingFollow = (my) -> {
  var ids = {
    following: null,
    followers: null
  }
  var list = {
    follow: null,
    unfollow: null
  }
  var node = {
    main: D.q("#main"),
    side: D.q("#side"),
    mirrorDebug: D.ce("textarea"),
    mirrorAna: D.ce("button").add(D.ct("Analyze")),
    mirrorBtn: O.sa(D.ce("button").add(D.ct("Mirror")), { disabled: true }),
    followCnt: D.ce("span").add(D.ct("0")),
    unfollowCnt: D.ce("span").add(D.ct("0")),
    followTotal: D.ce("span").add(D.ct("?")),
    unfollowTotal: D.ce("span").add(D.ct("?")),
    links: {
      follow: D.ce("ul"),
      unfollow: D.ce("ul")
    }
  }
  node.mirrorAna.addEventListener("click", -> mirrorAnalyze(); })
  node.mirrorBtn.addEventListener("click", ->
    if (confirm("sure?")) mirrorAnalyze(), mirror()
  })
  node.main.add(
    D.ce("h3").add(D.ct("Mirroring")),
    node.mirrorAna,
    node.mirrorBtn,
    D.ce("li").add(
      D.ct("follow: "), node.followCnt, D.ct(" / "), node.followTotal
    ),
    D.ce("li").add(
      D.ct("unfollow: "), node.unfollowCnt, D.ct(" / "), node.unfollowTotal
    ),
    node.mirrorDebug
  )
  node.side.add(
    D.ce("h3").add(D.ct("follow")),
    node.links.follow,
    D.ce("h3").add(D.ct("unfollow")),
    node.links.unfollow
  )
  function mirrorAnalyze() {
    list.follow = [], list.unfollow = []
    if (!ids.following || !ids.followers) return alert("not readied")
    ids.followers.forEach((follower_id) -> {
      if (ids.following.indexOf(follower_id) is -1) {
        list.follow.push(follower_id)
      }
    })
    ids.following.forEach((following_id) -> {
      if (ids.followers.indexOf(following_id) is -1) {
        list.unfollow.push(following_id)
      }
    })
    node.followTotal.textContent = list.follow.length
    node.unfollowTotal.textContent = list.unfollow.length
    D.empty(node.links.follow)
    D.empty(node.links.unfollow)
    D.add.apply(node.links.follow, list.follow.map((id) -> {
      return D.ce("li").add(
        D.ce("a").sa("href", U.ROOT + id + "@").add(D.ct(id)))
    }))
    D.add.apply(node.links.unfollow, list.unfollow.map((id) -> {
      return D.ce("li").add(
        D.ce("a").sa("href", U.ROOT + id + "@").add(D.ct(id)))
    }))
  }
  function mirror() {
    if (!list.follow || !list.unfollow) return
    var followCnt = 0, unfollowCnt = 0
    function finishFollow(uid) {
      node.mirrorDebug.value += "follow:" + uid + ", "
      node.followCnt.textContent = ++followCnt
    }
    function finishUnfollow(uid) {
      node.mirrorDebug.value += "unfollow:" + uid + ", "
      node.unfollowCnt.textContent = ++unfollowCnt
    }
    list.follow.forEach((follower_id, i) -> {
      X.post(API.urls.users.follow()(), "user_id=" + follower_id,
        -> finishFollow(follower_id); }, null, true)
    })
    list.unfollow.forEach((following_id, i) -> {
      X.post(API.urls.users.unfollow()(), "user_id=" + following_id,
        -> finishUnfollow(following_id); }, null, true)
    })
  }
  X.get(API.urls.users.friends_ids()() + "?user_id=" + my.id_str,
    (xhr) -> {
      var data = JSON.parse(xhr.responseText)
      ids.following = data.ids
    })
  X.get(API.urls.users.followers_ids()() + "?user_id=" + my.id_str,
    (xhr) -> {
      var data = JSON.parse(xhr.responseText)
      ids.followers = data.ids
    })
}

# step to render users list by ids
V.main.showUsersByIds = (url, my, mode) -> {
  var onScs = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    V.main.showUsersByLookup(data, url, my, mode)
  }
  # set ?count=<max>
  var urlpts = T.fixURL(url)
  delete urlpts.query["index"]
  delete urlpts.query["size"]
  var requrl = urlpts.base + "?" + T.strQuery(urlpts.query)
  mode |= 2
  X.get(requrl, onScs, V.misc.showXHRError)
  V.panel.showUserManager(my)
}

# lookup by ids.json
V.main.showUsersByLookup = (data, url, my, mode) -> {
  var it = V.main
  var object = it.genCursors(data, url)
  var index = object.index, size = object.size
  var sliced_ids = data.ids.slice(index, index + size);  # ids:[1, 23, 77]
  if (!sliced_ids.length) {
    D.q("#main").add(O.htmlify({"Empty": "No users found"}))
    return
  }
  # get users data with ids
  var onScs = (xhr) -> {
    var users = JSON.parse(xhr.responseText); # users:[1, 23, 77]
    users.sort((a, b) -> {
      return sliced_ids.indexOf(a.id_str) - sliced_ids.indexOf(b.id_str)
    })
    object["users"] = users
    LS.state.save("ids_object", object)
    it.rendUsers(object, my, mode)
  }
  X.get(API.urls.users.lookup()() + "?user_id=" + sliced_ids.join(","),
    onScs, V.misc.showXHRError)
  LS.state.save("ids_data", data)
  LS.state.save("ids_url", url)
  LS.state.save("ids_my", my)
  LS.state.save("ids_mode", mode)
}

# set cursor
V.main.genCursors = (data, url) -> {
  var qrys = T.fixURL(url).query
  var cursor = [].concat(qrys.cursor)[0] || "-1"
  var index = +([].concat(qrys.index)[0] || 0)
  var size = +([].concat(qrys.size)[0] || 20)
  /*
    [next_cursor_str, previous_cursor_str] ?query for ids API
    [next_index, prev_index, size]
      range of extraction [IDs] from {[ids.json]} for lookup API
  */
  var object = {}
  object.cursor = cursor
  object.index = index
  object.size = size
  # set next/prev page's users length
  object["size"] = size
  # set next page's parameters
  if (index + size < data.ids.length) {
    object["next_cursor_str"] = cursor
    object["next_index"] = index + size
  } else {
    object["next_cursor_str"] = data["next_cursor_str"]
    object["next_index"] = 0
  }
  # set prev page's parameters
  if (index - size >= 0) {
    object["previous_cursor_str"] = cursor
    object["prev_index"] = index - size
  } else {
    object["previous_cursor_str"] = data["previous_cursor_str"]
    object["prev_index"] = data["ids"].length - size
  }
  return object
}

# Render View of list of users
V.main.rendUsers = (data, my, mode) -> {
  var users = data.users || data
  var followerRequests = mode & 1
  var idsCursor = mode & 2
  var pageCursor = mode & 4
  var basicCursor = !idsCursor && !pageCursor
  var users_list = D.ce("ul").sa("id", "users")
  users && users.forEach((user) -> {
    var lu = {
      root: D.ce("li").sa("class", "user"),
      screen_name: D.ce("a").sa("href", U.ROOT + user.screen_name).
        sa("class", "screen_name").add(D.ct(user.screen_name)),
      icon: D.ce("img").sa("class", "user-icon").
        sa("src", user.profile_image_url_https).sa("alt", user.screen_name),
      name: D.ce("span").sa("class", "name").add(D.ct(T.decodeHTML(user.name))),
      description: D.ce("p").sa("class", "description").
        add(D.tweetize(user.description, user.entities.description)),
      created_at: D.ce("a").sa("class", "created_at").
        add(D.ct(T.gapTime(new Date(user.created_at))))
    }
    if (user.protected) lu.root.classList.add("protected")
    if (user.verified) lu.root.classList.add("verified")
    if (user.url) lu.created_at.href = user.entities.url.urls[0].expanded_url
    users_list.add(lu.root.add(
      lu.screen_name, lu.icon, lu.name, lu.description,
      D.ce("span").sa("class", "meta").add(lu.created_at),
      followerRequests ? V.panel.makeReqDecider(user): D.cf()
    ))
  })

  D.empty(D.q("#cursor"))
  D.empty(D.q("#main"))
  D.q("#main").add(
    users.length ? users_list: O.htmlify({"Empty": "No users found"}))

  basicCursor ? V.misc.showCursor(data):
  idsCursor ? V.misc.showCursorIds(data):
  pageCursor ? V.misc.showCursorPage(data): undefined

  addEventListener("scroll", V.main.onScroll)
  addEventListener("popstate",
    basicCursor ? V.main.cursorPopState:
    idsCursor ? V.main.cursorIdsPopState:
    pageCursor ? undefined: undefined
  )
}
