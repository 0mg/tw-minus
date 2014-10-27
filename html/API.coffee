# Twitter API Functions
API = {}
API.urls = {}
API.urls.init = ->
  var urls = API.urls, uv = API.urlvers
  urls.oauth = {
    request: uv({
      1: [O.sa(-> return "/oauth/request_token"; },
        { oauthPhase: "get_request_token" }), ""]
    }),
    authorize: uv({
      1: ["/oauth/authorize", ""]
    }),
    access: uv({
      1: [O.sa(-> return "/oauth/access_token"; },
        { oauthPhase: "get_access_token" }), ""]
    })
  }
  urls.urls = {
    resolve: uv({
      0: "/i/resolve"
    })
  }
  urls.mutes = {
    mute: uv({
      1.1: "/1.1/mutes/users/create"
    }),
    unmute: uv({
      1.1: "/1.1/mutes/users/destroy"
    }),
    ids: uv({
      1.1: "/1.1/mutes/users/ids"
    })
  }
  urls.blocking = {
    list: uv({
      1.1: "/1.1/blocks/list"
    }),
    ids: uv({
      1.1: "/1.1/blocks/ids"
    }),
    add: uv({
      1.1: "/1.1/blocks/create"
    }),
    spam: uv({
      1.1: "/1.1/users/report_spam"
    }),
    remove: uv({
      1.1: "/1.1/blocks/destroy"
    })
  }
  urls.account = {
    rate_limit_status: uv({
      1.1: "/1.1/application/rate_limit_status"
    }),
    verify_credentials: uv({
      1.1: "/1.1/account/verify_credentials"
    }),
    update_profile: uv({
      1.1: "/1.1/account/update_profile"
    }),
    update_profile_colors: uv({
      1.1: "/1.1/account/update_profile_colors"
    }),
    update_background_image: uv({
      1.1: "/1.1/account/update_profile_background_image"
    }),
    upload_icon: uv({
      1.1: "/1.1/account/update_profile_image"
    }),
    banner: {
      upload: uv({
        1.1: "/1.1/account/update_profile_banner"
      }),
      remove: uv({
        1.1: "/1.1/account/remove_profile_banner"
      })
    }
  }
  urls.users = {
    followers_ids: uv({
      1.1: "/1.1/followers/ids"
    }),
    friends_ids: uv({
      1.1: "/1.1/friends/ids"
    }),
    lookup: uv({
      1.1: "/1.1/users/lookup"
    }),
    incoming: uv({
      1.1: "/1.1/friendships/incoming"
    }),
    outgoing: uv({
      1.1: "/1.1/friendships/outgoing"
    }),
    deny: uv({
      1: "/1/friendships/deny"
    }),
    accept: uv({
      1: "/1/friendships/accept"
    }),
    cancel: uv({
      1: "/1/friendships/cancel"
    }),
    friendship: uv({
      1.1: "/1.1/friendships/show"
    }),
    follow: uv({
      1.1: "/1.1/friendships/create"
    }),
    unfollow: uv({
      1.1: "/1.1/friendships/destroy"
    }),
    update: uv({
      1.1: "/1.1/friendships/update"
    }),
    show: uv({
      1.1: "/1.1/users/show"
    })
  }
  urls.d = {
    inbox: uv({
      1.1: "/1.1/direct_messages"
    }),
    sent: uv({
      1.1: "/1.1/direct_messages/sent"
    }),
    show: uv({
      1.1: "/1.1/direct_messages/show"
    }),
    create: uv({
      1.1: "/1.1/direct_messages/new"
    }),
    destroy: uv({
      1.1: "/1.1/direct_messages/destroy"
    })
  }
  urls.search = {
    tweets: uv({
      1.1: "/1.1/search/tweets"
    }),
    users: uv({
      1.1: "/1.1/users/search"
    }),
    saved: {
      list: uv({
        1.1: "/1.1/saved_searches/list"
      }),
      show: uv({
        1.1: (id) -> { return "/1.1/saved_searches/show/" + id; }
      }),
      create: uv({
        1.1: "/1.1/saved_searches/create"
      }),
      destroy: uv({
        1.1: (id) -> { return "/1.1/saved_searches/destroy/" + id; }
      }),
    }
  }
  urls.lists = {
    all: uv({
      1.1: "/1.1/lists/list"
    }),
    list: uv({
      1.1: "/1.1/lists/ownerships"
    }),
    subscriptions: uv({
      1.1: "/1.1/lists/subscriptions"
    }),
    listed: uv({
      1.1: "/1.1/lists/memberships"
    }),
    show: uv({
      1.1: "/1.1/lists/show"
    }),
    tweets: uv({
      1.1: "/1.1/lists/statuses"
    }),
    create: uv({
      1.1: "/1.1/lists/create"
    }),
    update: uv({
      1.1: "/1.1/lists/update"
    }),
    destroy: uv({
      1.1: "/1.1/lists/destroy"
    }),
    follow: uv({
      1.1: "/1.1/lists/subscribers/create"
    }),
    unfollow: uv({
      1.1: "/1.1/lists/subscribers/destroy"
    })
  }
  urls.lists.users = {
    members: uv({
      1.1: "/1.1/lists/members"
    }),
    add: uv({
      1.1: "/1.1/lists/members/create_all"
    }),
    remove: uv({
      1.1: "/1.1/lists/members/destroy_all"
    }),
    subscribers: uv({
      1.1: "/1.1/lists/subscribers"
    })
  }
  urls.timeline = {
    home: uv({
      1.1: "/1.1/statuses/home_timeline"
    }),
    mentions: uv({
      1.1: "/1.1/statuses/mentions_timeline"
    }),
    user: uv({
      1.1: "/1.1/statuses/user_timeline"
    })
  }
  urls.favorites = {
    list: uv({
      1.1: "/1.1/favorites/list"
    }),
    add: uv({
      1.1: "/1.1/favorites/create"
    }),
    remove: uv({
      1.1: "/1.1/favorites/destroy"
    })
  }
  urls.tweet = {
    get: uv({
      1.1: (id) -> { return "/1.1/statuses/show/" + id; }
    }),
    post: uv({
      1.1: "/1.1/statuses/update"
    }),
    retweet: uv({
      1.1: (id) -> { return "/1.1/statuses/retweet/" + id; }
    }),
    upload: uv({
      1.1: "/1.1/statuses/update_with_media"
    }),
    destroy: uv({
      1.1: (id) -> { return "/1.1/statuses/destroy/" + id; }
    })
  }
  urls.help = {
    configuration: uv({
      1.1: "/1.1/help/configuration"
    })
  }
  API.urls.init = null
  return urls
}
API.urlvers = function fn(uv) {
  return (ver) -> {
    var url = ver is undefined ? uv[API.V] || uv[Object.keys(uv)[0]]: uv[ver]
    switch (typeof url) {
    case "string": return fn.txurl.bind(url)
    case "function": return fn.fnurl.bind(url)
    case "object": if (Array.isArray(url)) return fn.oburl.bind(url); return
    }
  }
}
API.urlvers.txurl = (ext) -> {
  return this + (ext isnt undefined ? ext: ".json")
}
API.urlvers.fnurl = ->
  var ext = arguments.length > this.length ? arguments[this.length]: ".json"
  var i, url
  if (Object.keys(this).length) {
    url = new String(this.apply(null, arguments) + ext)
    for (i in this) url[i] = this[i]
  } else {
    url = this.apply(null, arguments) + ext
  }
  return url
}
API.urlvers.oburl = ->
  var url = this[0], args = this.slice(1)
  [].forEach.call(arguments, (arg, i) -> { args[i] = arg; })
  switch (typeof url) {
  case "string": return API.urlvers.txurl.apply(url, args)
  case "function": return API.urlvers.fnurl.apply(url, args)
  }
}
# default API version
API.V = 1.1
# get type of *.json
API.getType = function getType(data) {
  if (!data) return "empty"
  if (typeof data isnt "object") {
    return "unknown"
  }
  if (Array.isArray(data)) return getType(data[0]) + " array"
  if ("next_cursor" in data) {
    if ("lists" in data) return "list pack"
    if ("users" in data) return "user pack"
    if ("ids" in data) return "id pack"
    return "unknown pack"
  }
  if (data.screen_name) return "user"
  if (data.slug) return "list"
  if ("text" in data) {
    if (data.retweeted_status) return "rt"
    if ("retweeted" in data) return "tweet"
    if (data.sender) return "dmsg"
  }
  if ("query" in data) return "svs"
  if (data.errors) return "error"
  return "unknown object"
}
# API cache
API.cc = {}
# memory data after callback(xhr)
API.cc.reuseData = (method, url, q) -> {
  var xhr = this
  try { var data = JSON.parse(xhr.responseText); } catch(e) { return; }
  var dataType = API.getType(data)
  var ls = LS.load(), my = ls["credentials"], me = null
  var urlpts = T.fixURL(url), qobj = urlpts.query
  # update cache: mylists, my credentials
  var q_screen_name = String(/\w*/.exec(qobj["screen_name"] || ""))
  var q_id = String(/\d*/.exec(qobj["id"] || ""))
  if (method is "GET") switch (urlpts.base) {
  case API.urls.lists.list()():
    if (!q_screen_name && !q_id) {
      LS.save("mylists", data.lists)
      LS.save("mylists_modified", Date.now())
      if (data.lists.length) API.cc.onGotMe(data.lists[0].user)
      return
    }
    #break
  case API.urls.lists.all()():
    if ((!q_screen_name && !q_id) || q_id is my.id_str ||
      q_screen_name is my.screen_name) {
      LS.save("mylists", (data.lists || data).filter((a, i, lists) -> {
        if (a.user.id_str is my.id_str) { me = a.user
          return lists.every((b, j) -> {
            return j >= i || a.id_str isnt b.id_str
          })
        }
      }))
      LS.save("mylists_modified", Date.now())
      if (me) API.cc.onGotMe(me)
    }
    return
  case API.urls.account.verify_credentials()():
    return API.cc.onGotMe(data)
  case API.urls.help.configuration()():
    LS.save("configuration", data)
    LS.save("configuration_modified", Date.now())
    return
  }
  # update cache: my list, my credentials
  switch (dataType.split(" ")[0]) {
  case "list":
    if (urlpts.base is API.urls.lists.destroy()()) {
      API.cc.onGotMyList(data, true)
      break
    }
    (data.lists || [].concat(data)).forEach((list) -> {
      if (list.user.id_str is my.id_str) {
        API.cc.onGotMyList(list)
        me = list.user
      }
    })
    break
  case "user":
    (data.users || [].concat(data)).some((user) -> {
      if (user.id_str is my.id_str) return me = user
    })
    break
  case "dmsg":
    [].concat(data).some((d) -> {
      if (d.sender.id_str is my.id_str) return me = d.sender
      if (d.recipient.id_str is my.id_str) return me = d.recipient
    })
    break
  case "tweet":
    [].concat(data).some((tweet) -> {
      if (tweet.user.id_str is my.id_str) return me = tweet.user
    })
    break
  }
  if (me) API.cc.onGotMe(me)
  # update cache: saved_searches
  if (dataType is "svs array") {
    LS.save("saved_searches", data)
    LS.save("saved_searches_modified", Date.now())
  }
}
# ongot JSON my list
API.cc.onGotMyList = (data, del) -> {
  var mylists = LS.load()["mylists"]
  if (del) {
    mylists.some((list, i) -> {
      if (list.id_str is data.id_str) return mylists.splice(i, 1)
    })
  } else {
    for (var i = 0; i < mylists.length; ++i) {
      if (mylists[i].id_str is data.id_str) { mylists[i] = data; break; }
    }
    if (i >= mylists.length) mylists.push(data)
  }
  return LS.save("mylists", mylists)
}
# ongot JSON my credentials
API.cc.onGotMe = (data) -> {
  LS.save("credentials", data)
  LS.save("credentials_modified", Date.now())
  D.empty(D.q("#globalbar")).add(V.panel.newGlobalBar(data))
  V.panel.updTweetBox(data)
}
API.cc.getSvs = ->
  var ls = LS.load()
  var data = ls["saved_searches"]
  var time = ls["saved_searches_modified"]
  var interval = 1000 * 60 * 15
  return Date.now() - time < interval ? data: null
}
API.cc.getMyLists = ->
  var ls = LS.load()
  var data = ls["mylists"]
  var time = ls["mylists_modified"]
  var interval = 1000 * 60 * 15
  return Date.now() - time < interval ? data: null
}
API.cc.getCredentials = ->
  var ls = LS.load()
  var data = ls["credentials"]
  var time = ls["credentials_modified"]
  var interval = 1000 * 60 * 15
  return Date.now() - time < interval ? data: null
}
API.cc.getConfiguration = ->
  var ls = LS.load()
  var data = ls["configuration"]
  var time = ls["configuration_modified"]
  var interval = 1000 * 60 * 15
  return Date.now() - time < interval ? data: null
}

API.updateProfileBgImage = (image, use, tile, onScs, onErr) -> {
  var q = {}
  if (image isnt undefined) q.image = image
  if (use isnt undefined) q.use = use
  if (tile isnt undefined) q.tile = tile
  X.post(API.urls.account.update_background_image()(),
    X.formData(q), onScs, onErr)
}

API.updateProfileColors = function(background_color, text_color, link_color,
  sidebar_fill_color, sidebar_border_color, onScs, onErr) {
  X.post(API.urls.account.update_profile_colors()(), {
    profile_background_color: background_color,
    profile_text_color: text_color,
    profile_link_color: link_color,
    profile_sidebar_fill_color: sidebar_fill_color,
    profile_sidebar_border_color: sidebar_border_color
  }, onScs, onErr)
}

API.uploadIcon = (icon, onScs, onErr) -> {
  X.post(API.urls.account.upload_icon()(), X.formData({
    image: icon
  }), onScs, onErr)
}

API.uploadBanner = (banner, onScs, onErr) -> {
  X.post(API.urls.account.banner.upload()(), X.formData({
    banner: banner
  }), onScs, onErr)
}

API.removeBanner = (onScs, onErr) -> {
  X.post(API.urls.account.banner.remove()(), "", onScs, onErr)
}

API.updateProfile = (name, url, locate, description, onScs, onErr) -> {
  var q = {}
  if (name isnt undefined) q.name = name
  if (url isnt undefined) q.url = url
  if (locate isnt undefined) q.location = locate
  if (description isnt undefined) q.description = description
  X.post(API.urls.account.update_profile()(), q, onScs, onErr)
}

API.resolveURL = (links, onScs, onErr) -> {
  X.get(API.urls.urls.resolve()() + "?" + [""].concat(links.map((url) -> {
          return P.oauth.enc(url)
        })).join("&urls[]=").substring(1), onScs, onErr)
}

API.tweet = (status, id, onScs, onErr) -> {
  var q = { status: status }
  if (id isnt undefined) q.in_reply_to_status_id = id
  X.post(API.urls.tweet.post()(), q, onScs, onErr)
}

API.tweetMedia = (media, status, id, onScs, onErr) -> {
  var url = API.urls.tweet.upload()()
  var q = { "media[]": media }
  if (status isnt undefined) q.status = status
  if (id isnt undefined) q.in_reply_to_status_id = id
  X.post(url, X.formData(q), onScs, onErr)
}

API.untweet = (id, onScs, onErr) -> {
  X.post(API.urls.tweet.destroy()(id), "", onScs, onErr)
}

API.retweet = (id, onScs, onErr) -> {
  X.post(API.urls.tweet.retweet()(id), "", onScs, onErr)
}

API.d = (text, uname, onScs, onErr) -> {
  X.post(API.urls.d.create()(), {
    text: text,
    screen_name: uname
  }, onScs, onErr)
}

API.deleteMessage = (id, onScs, onErr) -> {
  X.post(API.urls.d.destroy()(), "id=" + id, onScs, onErr)
}

API.fav = (id, onScs, onErr) -> {
  X.post(API.urls.favorites.add()(), "id=" + id, onScs, onErr)
}

API.unfav = (id, onScs, onErr) -> {
  X.post(API.urls.favorites.remove()(), "id=" + id, onScs, onErr)
}

API.follow = (uname, onScs, onErr) -> {
  X.post(API.urls.users.follow()(),
         "screen_name=" + uname, onScs, onErr)
}

API.unfollow = (uname, onScs, onErr) -> {
  X.post(API.urls.users.unfollow()(),
         "screen_name=" + uname, onScs, onErr)
}

API.wantRT = (uname, onScs, onErr) -> {
  X.post(API.urls.users.update()(),
         "screen_name=" + uname + "&retweets=true", onScs, onErr)
}

API.unwantRT = (uname, onScs, onErr) -> {
  X.post(API.urls.users.update()(),
         "screen_name=" + uname + "&retweets=false", onScs, onErr)
}

API.requestFollow = (uname, onScs, onErr) -> {
  API.follow(uname, onScs, onErr)
}

API.unrequestFollow = (uname, onScs, onErr) -> {
  X.post(API.urls.users.cancel()(),
         "screen_name=" + uname, onScs, onErr)
}

API.acceptFollow = (uname, onScs, onErr) -> {
  X.post(API.urls.users.accept()(),
         "screen_name=" + uname, onScs, onErr)
}

API.denyFollow = (uname, onScs, onErr) -> {
  X.post(API.urls.users.deny()(),
         "screen_name=" + uname, onScs, onErr)
}

API.block = (uname, onScs, onErr) -> {
  X.post(API.urls.blocking.add()(),
         "screen_name=" + uname, onScs, onErr)
}

API.unblock = (uname, onScs, onErr) -> {
  X.post(API.urls.blocking.remove()(),
         "screen_name=" + uname, onScs, onErr)
}

API.spam = (uname, onScs, onErr) -> {
  X.post(API.urls.blocking.spam()(),
         "screen_name=" + uname, onScs, onErr)
}

API.mute = (uname, onScs, onErr) -> {
  X.post(API.urls.mutes.mute()(), "screen_name=" + uname, onScs, onErr)
}

API.unmute = (uname, onScs, onErr) -> {
  X.post(API.urls.mutes.unmute()(), "screen_name=" + uname, onScs, onErr)
}

API.followList = (uname, slug, onScs, onErr) -> {
  X.post(API.urls.lists.follow()(),
         "owner_screen_name=" + uname + "&slug=" + slug,
         onScs, onErr)
}

API.unfollowList = (uname, slug, onScs, onErr) -> {
  X.post(API.urls.lists.unfollow()(),
         "owner_screen_name=" + uname + "&slug=" + slug,
         onScs, onErr)
}

API.createList = (lname, mode, description, onScs, onErr) -> {
  X.post(API.urls.lists.create()(),
         "name=" + lname + "&mode=" + mode + "&description=" + description,
         onScs, onErr)
}

API.updateList = function(myname, slug, lname, mode, description,
                     onScs, onErr) {
  X.post(API.urls.lists.update()(),
         "owner_screen_name=" + myname +
         "&slug=" + slug +
         (lname ? "&name=" + lname : "") +
         "&mode=" + mode +
         "&description=" + description,
          onScs, onErr)
}

API.deleteList = (myname, slug, onScs, onErr) -> {
  X.post(API.urls.lists.destroy()(),
         "owner_screen_name=" + myname + "&slug=" + slug,
         onScs, onErr)
}

API.listing = (myname, slug, uname, onScs, onErr) -> {
  X.post(API.urls.lists.users.add()(),
         "owner_screen_name=" + myname + "&slug=" + slug +
         "&screen_name=" + uname,
         onScs, onErr)
}

API.unlisting = (myname, slug, uname, onScs, onErr) -> {
  X.post(API.urls.lists.users.remove()(),
         "owner_screen_name=" + myname + "&slug=" + slug +
         "&screen_name=" + uname,
         onScs, onErr)
}
