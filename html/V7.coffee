# Action buttons panel for follow, unfollow, spam.,
V.panel.showFollowPanel = (user) -> {
  var ship = {
    blocking: false,
    followed_by: false,
    marked_spam: false,
    want_retweets: false,
    muting: false
  }
  var ab = {
    node: D.cf(),
    follow: new V.Button("Follow", "Unfollow"),
    block: new V.Button("Block", "Unblock"),
    spam: new V.Button("Spam", "Unspam"),
    req_follow: new V.Button("ReqFollow", "UnreqFollow"),
    dm: new V.Button("D"),
    want_rt: new V.Button("WantRT", "UnwantRT"),
    mute: new V.Button("Mute", "Unmute")
  }
  var update = (xhr) -> {
    /*if (xhr && xhr.status is 200) {
      #API may return old data
      var data = JSON.parse(xhr.responseText)
      if (data.relationship) ship = data.relationship.source; else user = data
    }/**/
    # state
    ab.follow.turn(user.following)
    ab.req_follow.turn(user.follow_request_sent)
    ab.block.turn(ship.blocking || ship.marked_spam)
    ab.spam.turn(ship.marked_spam)
    ab.want_rt.turn(ship.want_retweets)
    ab.mute.turn(ship.muting)
    # visibility
    if ((!user.protected || user.following) && !ship.blocking) {
      ab.follow.show().enable()
    } else ab.follow.hide().disable()
    if (user.protected && !user.following && !ship.blocking) {
      ab.req_follow.show().enable()
    } else ab.req_follow.hide().disable()
    if (true) ab.block.show().enable()
    else ab.block.hide().disable()
    if (!ship.marked_spam) ab.spam.show().enable()
    else ab.spam.hide().disable()
    if (user.following) ab.want_rt.show().enable()
    else ab.want_rt.hide().disable()
    if (ship.followed_by) ab.dm.show().enable()
    else ab.dm.hide().disable()
  }
  /*
  # user
    following
    follow_request_sent
    protected
  # ship
    blocking
    followed_by
    marked_spam
    want_retweets
    muting
  */
  var onFollow = (xhr) -> {
    user.following = true
    #user.follow_request_sent
    ship.blocking = false
    #ship.followed_by
    ship.marked_spam = false
    ship.want_retweets = true
    #ship.muting
    update(xhr)
  }
  var onUnfollow = (xhr) -> {
    user.following = false
    #user.follow_request_sent
    #ship.blocking
    #ship.followed_by
    #ship.marked_spam
    ship.want_retweets = false
    #ship.muting
    update(xhr)
  }
  var onReq = (xhr) -> {
    #user.following
    user.follow_request_sent = true
    ship.blocking = false
    #ship.followed_by
    ship.marked_spam = false
    #ship.want_retweets
    #ship.muting
    update(xhr)
  }
  var onUnreq = (xhr) -> {
    #user.following
    user.follow_request_sent = false
    #ship.blocking
    #ship.followed_by
    #ship.marked_spam
    #ship.want_retweets
    #ship.muting
    update(xhr)
  }
  var onBlock = (xhr) -> {
    user.following = false
    user.follow_request_sent = false
    ship.blocking = true
    ship.followed_by = false
    ship.marked_spam = true
    ship.want_retweets = false
    #ship.muting
    update(xhr)
  }
  var onUnblock = (xhr) -> {
    #user.following
    #user.follow_request_sent
    ship.blocking = false
    #ship.followed_by
    ship.marked_spam = false
    #ship.want_retweets
    #ship.muting
    update(xhr)
  }
  var onSpam = (xhr) -> {
    user.following = false
    user.follow_request_sent = false
    ship.blocking = true
    ship.followed_by = false
    ship.marked_spam = true
    ship.want_retweets = false
    #ship.muting
    update(xhr)
  }
  var onWantRT = (xhr) -> {
    #user.following
    #user.follow_request_sent
    #ship.blocking
    #ship.followed_by
    #ship.marked_spam
    ship.want_retweets = true
    #ship.muting
    update(xhr)
  }
  var onUnwantRT = (xhr) -> {
    #user.following
    #user.follow_request_sent
    #ship.blocking
    #ship.followed_by
    #ship.marked_spam
    ship.want_retweets = false
    #ship.muting
    update(xhr)
  }
  var onMute = (xhr) -> {
    #user.following
    #user.follow_request_sent
    #ship.blocking
    #ship.followed_by
    #ship.marked_spam
    #ship.want_retweets
    ship.muting = true
    update(xhr)
  }
  var onUnmute = (xhr) -> {
    #user.following
    #user.follow_request_sent
    #ship.blocking
    #ship.followed_by
    #ship.marked_spam
    #ship.want_retweets
    ship.muting = false
    update(xhr)
  }
  ab.follow.node.addEventListener("click", ->
    ab.follow.on ?
      API.unfollow(user.screen_name, onUnfollow, update):
      API.follow(user.screen_name, onFollow, update)
  })
  ab.req_follow.node.addEventListener("click", ->
    ab.req_follow.on ?
      API.unrequestFollow(user.screen_name, onUnreq, update):
      API.requestFollow(user.screen_name, onReq, update)
  })
  ab.block.node.addEventListener("click", ->
    ab.block.on ?
      API.unblock(user.screen_name, onUnblock, update):
      API.block(user.screen_name, onBlock, update)
  })
  ab.spam.node.addEventListener("click", ->
    ab.spam.on ?
      API.unblock(user.screen_name, onUnblock, update):
      API.spam(user.screen_name, onSpam, update)
  })
  ab.want_rt.node.addEventListener("click", ->
    ab.want_rt.on ?
      API.unwantRT(user.screen_name, onUnwantRT, update):
      API.wantRT(user.screen_name, onWantRT, update)
  })
  ab.dm.node.addEventListener("click", ->
    var status = D.q("#status")
    status.value = "d " + user.screen_name + " " + status.value
    D.ev(status, "input").focus()
  })
  ab.mute.node.addEventListener("click", ->
    ab.mute.on ?
      API.unmute(user.screen_name, onUnmute, update):
      API.mute(user.screen_name, onMute, update)
  })
  ab.node.add(
    ab.follow.node,
    ab.req_follow.node,
    ab.block.node,
    ab.spam.node,
    ab.want_rt.node,
    ab.mute.node,
    ab.dm.node
  )
  update(null)
  D.q("#subaction-inner-1").add(ab.node)
  var onScs = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    ship = data.relationship.source
    update(xhr)
  }
  var onErr = ->
    ab.block.turn(undefined)
    ab.spam.turn(undefined)
    ab.want_rt.turn(undefined)
    ab.dm.turn(undefined).show().enable()
  }
  X.get(API.urls.users.friendship()() + "?target_id=" + user.id_str,
        onScs, onErr)
}
# Action buttons panel for add user to list
V.panel.showAddListPanel = (user, my) -> {
  var it = V.panel
  var onScs = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    var expander = D.ce("button").add(D.ct("Lists"))
    expander.addEventListener("click", ->
      D.rm(expander); it.lifeListButtons(data.lists || data, user, my)
    })
    D.q("#subaction-inner-1").add(expander)
  }
  var mylists = API.cc.getMyLists()
  if (mylists) {
    onScs({responseText:JSON.stringify(mylists)})
  } else {
    X.get(API.urls.lists.list()(), onScs, null)
  }
}
V.panel.lifeListButtons = (lists, user, my) -> {
  var al = {
    node: D.ce("div")
  }
  var list_btns = {}
  lists.forEach((l) -> {
    var lb_label = (l.mode is "private" ? "-": "+") + l.slug
    var lb = new V.Button(lb_label)
    list_btns[l.slug] = lb
    function onListing() { lb.turn(true); }
    function onUnlisting() { lb.turn(false); }
    lb.node.addEventListener("click", ->
      lb.on ? API.unlisting(l.user.screen_name, l.slug,
                            user.screen_name, onUnlisting):
              API.listing(l.user.screen_name, l.slug,
                          user.screen_name, onListing)
    })
    al.node.add(lb.node)
  })
  var onScs = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    data.lists.forEach((l) -> {
      list_btns[l.slug].turn(true)
    })
  }
  var onErr = ->
    for (var i in list_btns) list_btns[i].turn(undefined)
  }
  D.q("#subaction-inner-2").add(al.node)
  X.get(API.urls.lists.listed()() + "?filter_to_owned_lists=true&" +
        "screen_name=" + user.screen_name, onScs, onErr)
}

# Button to do follow list
V.panel.showListFollowPanel = (list) -> {
  var ab = {
    node: D.ce("div"),
    follow: new V.Button("Follow", "Unfollow")
  }
  function onFollow() { ab.follow.turn(true); }
  function onUnfollow() { ab.follow.turn(false); }
  list.following && onFollow()
  ab.follow.node.addEventListener("click", ->
    ab.follow.on ?
      API.unfollowList(list.user.screen_name, list.slug, onUnfollow):
      API.followList(list.user.screen_name, list.slug, onFollow)
  })
  ab.node.add(ab.follow.node)
  D.q("#subaction").add(ab.node)
}

# Global bar: links to home, profile, mentions, lists.,
V.panel.newGlobalBar = (my) -> {
  var g = {
    bar: D.cf(),
    home: D.ce("a"),
    profile: D.ce("a"),
    replies: D.ce("a"),
    inbox: D.ce("a"),
    sent: D.ce("a"),
    favorites: D.ce("a"),
    following: D.ce("a"),
    followers: D.ce("a"),
    follow_req_in: D.ce("a"),
    follow_req_out: D.ce("a"),
    lists: D.ce("a"),
    listown: D.ce("a"),
    listsub: D.ce("a"),
    listed: D.ce("a"),
    users: D.ce("a"),
    settings: D.ce("a"),
    logout: D.ce("button"),

    tweets_len: D.ce("span").sa("class", "statuses_count"),
    screen_name: D.ce("span").sa("class", "screen_name"),
    fav_len: D.ce("span").sa("class", "favourites_count"),
    fwing_len: D.ce("span").sa("class", "friends_count"),
    fwers_len: D.ce("span").sa("class", "followers_count"),
    listed_len: D.ce("span").sa("class", "listed_count")
  }
  g.profile.href = U.ROOT + my.screen_name
  g.tweets_len.textContent = my.statuses_count
  g.screen_name.textContent = my.screen_name
  g.fav_len.textContent = my.favourites_count
  g.fwing_len.textContent = my.friends_count
  g.fwers_len.textContent = my.followers_count
  g.listed_len.textContent = my.listed_count

  g.home.href = U.ROOT
  g.home.add(D.ct("Home"))

  g.profile.href = U.ROOT + my.screen_name
  g.profile.add(D.ct("Profile:"), g.tweets_len)

  g.replies.href = U.ROOT + "mentions"
  g.replies.add(D.ct("@"), g.screen_name)

  g.inbox.href = U.ROOT + "inbox"
  g.inbox.add(D.ct("Inbox"))

  g.sent.href = U.ROOT + "sent"
  g.sent.add(D.ct("Sent"))

  g.favorites.href = U.ROOT + "favorites"
  g.favorites.add(D.ct("Favorites:"), g.fav_len)

  g.following.href = U.ROOT + "following"
  g.following.add(D.ct("Following:"), g.fwing_len)

  g.followers.href = U.ROOT + "followers"
  g.followers.add(D.ct("Followers:"), g.fwers_len)

  g.follow_req_in.href = U.ROOT + "followers/requests"
  g.follow_req_in.add(D.ct("requests in"))

  g.follow_req_out.href = U.ROOT + "following/requests"
  g.follow_req_out.add(D.ct("requests out"))

  g.lists.href = U.ROOT + "lists"
  g.lists.add(D.ct("Lists"))

  g.listown.href = U.ROOT + "lists/ownerships"
  g.listown.add(D.ct("Ownerships"))

  g.listsub.href = U.ROOT + "lists/subscriptions"
  g.listsub.add(D.ct("Subscriptions"))

  g.listed.href = U.ROOT + "lists/memberships"
  g.listed.add(D.ct("Listed:"), g.listed_len)

  g.users.href = U.ROOT + "users"
  g.users.add(D.ct("Users"))

  g.settings.href = U.ROOT + "settings"
  g.settings.add(D.ct("Settings"))

  g.logout.add(D.ct("logout"))
  g.logout.addEventListener("click", ->
    var lsdata = LS.load()
    var keep = ["consumer_secret"]
    if (confirm("DELETE authentication cache sure?")) {
      LS.reset()
      keep.forEach((i) -> { LS.save(i, lsdata[i]); })
      location.href = U.ROOT + "login"
    }
  })

  g.bar.add(
    D.ce("li").add(g.home),
    D.ce("li").add(g.profile),
    D.ce("li").add(g.replies),
    D.ce("li").add(g.inbox, D.ce("ul").add(D.ce("li").add(g.sent))),
    D.ce("li").add(g.favorites),
    D.ce("li").add(g.following,
      D.ce("ul").add(D.ce("li").add(g.follow_req_out))),
    D.ce("li").add(g.followers,
      D.ce("ul").add(D.ce("li").add(g.follow_req_in))),
    D.ce("li").add(g.lists,
      D.ce("ul").add(
        D.ce("li").add(g.listown),
        D.ce("li").add(g.listsub)
      )
    ),
    D.ce("li").add(g.listed),
    D.ce("li").add(g.users, V.main.newUsers(my)),
    D.ce("li").add(g.settings, V.main.newSettings(my)),
    D.ce("li").add(g.logout)
  )
  return g.bar
}
