# Global Tweet box
V.panel.updTweetBox = (my) -> {
  var nd = V.panel.tweetbox
  nd.usname.textContent = my.screen_name
  nd.usname.sa("href", U.ROOT + my.screen_name)
  nd.uicon.sa("src", my.profile_image_url_https || "data:")
  nd.uicon.sa("alt", my.screen_name)
  nd.uname.textContent = T.decodeHTML(my.name)
}
V.panel.tweetbox = null
V.panel.newTweetBox = (my) -> {
  var media_files = null
  var nd = {
    box: D.cf(),
    profile: D.ce("div").sa("id", "status_profile"),
    usname: D.ce("a").sa("class", "screen_name"),
    uicon: D.ce("img").sa("class", "user-icon"),
    uname: D.ce("span").sa("class", "name"),
    status: D.ce("textarea").sa("id", "status"),
    id: D.ce("input").sa("id", "in_reply_to_status_id"),
    to_uname: D.ce("input").sa("id", "in_reply_to_screen_name"),
    update: D.ce("button").sa("id", "status_update").add(D.ct("Tweet")),
    replink: D.ce("a").sa("id", "reply_target_link").
      sa("class", "in_reply_to"),
    imgvw: D.ce("ul").sa("id", "status_media_preview"),
    usemedia: D.ce("input").sa("id", "status_media_use").
      sa("type", "checkbox").sa("disabled", "disabled"),
    media: O.sa(D.ce("input").sa("id", "status_media").sa("type", "file"),
      { multiple: LS.load().configuration.max_media_per_upload > 1 })
  }
  V.panel.tweetbox = nd
  V.panel.updTweetBox(my)
  var switchReplyTarget = ->
    var tid = nd.id.value, uname = nd.to_uname.value
    # reset
    [].forEach.call(D.qs(".reply_target"), (reptgt) -> {
      reptgt.classList.remove("reply_target")
      reptgt.q(".reply").sa("aria-pressed", false)
    })
    nd.replink.classList.remove("replying")
    # update reply target
    var reptgt = D.q(".tweet.id-" + tid)
    if (reptgt) {
      reptgt.classList.add("reply_target")
      reptgt.q(".reply").sa("aria-pressed", true)
    }
    # update replink
    if (tid && nd.status.value.match("@" + uname + "\\b")) {
      nd.replink.textContent = "in reply to " + uname
      nd.replink.sa("href", U.ROOT + uname + "/status/" + tid)
      nd.replink.classList.add("replying")
      return true
    }
  }
  var onCheck = ->
    nd.imgvw.classList[nd.usemedia.checked ? "add": "remove"]("use_media")
  }
  var onTweet = (xhr) -> {
    var data = JSON.parse(xhr.responseText)
    D.q("#status_log").ins(V.main.newTweet(data, my))
    D.empty(D.q("#status_section")).add(V.panel.newTweetBox(my))
  }
  var onInput = ->
    var replying = switchReplyTarget()
    var red = /^d\s+\w+\s*/
    var reurl = /\bhttps?:\/\/[-\w.!~*'()%@:$,;&=+/?#\[\]]+/g
    var conf = LS.load()["configuration"]
    nd.update.textContent =
      replying ? "Reply": red.test(nd.status.value) ? "D": "Tweet"
    nd.update.disabled = nd.status.value.replace(red, "").
      replace(reurl, (url) -> {
        var key = /^https/.test(url) ?
          "short_url_length_https" : "short_url_length"
        return Array(1 + conf[key]).join("c"); #t.co
      }).
      replace(/[\ud800-\udbff][\udc00-\udfff]/g, "c").length +
      nd.usemedia.checked * conf.characters_reserved_per_media > 140
  }
  # add event listeners
  nd.status.addEventListener("input", onInput)
  nd.update.addEventListener("click", ->
    var d_ma = nd.status.value.match(/^d\s+(\w+)\s?([\S\s]*)/)
    if (nd.usemedia.checked) {
      API.tweetMedia(media_files, nd.status.value, nd.id.value, onTweet)
    } else if (d_ma) {
      API.d(d_ma[2], d_ma[1], onTweet)
    } else {
      API.tweet(nd.status.value, nd.id.value, onTweet)
    }
  })
  nd.usemedia.addEventListener("change", ->
    onCheck()
    onInput()
  })
  nd.media.addEventListener("change", ->
    if (!(nd.usemedia.disabled = !nd.media.files.length)) {
      media_files = nd.media.files
      nd.usemedia.checked = !!nd.media.files.length
      onCheck()
    }
    onInput()
    D.empty(nd.imgvw)
    [].forEach.call(nd.media.files, (file) -> {
      var fr = new FileReader
      fr.addEventListener("load", ->
        var url = "data:" + file.type + ";base64," + btoa(fr.result)
        nd.imgvw.add(D.ce("li").add(
          D.ce("a").sa("href", url).add(
            D.ce("img").sa("class", "media_image").
              sa("alt", file.name).sa("src", url)
          )
        ))
      })
      fr.readAsBinaryString(file)
    })
  })
  nd.replink.addEventListener("click", (v) -> {
    var e = D.q(".tweet.id-" + nd.id.value); if (!e) return
    nd.replink.disabled = true
    e.scrollIntoView()
    e.classList.add("focus")
    setTimeout(->
      e.classList.remove("focus")
      nd.replink.disabled = false
    }, 500)
    v.preventDefault()
  })
  # init
  switchReplyTarget()
  # render tweet box
  nd.profile.add(
    nd.usname, nd.uicon, nd.uname, nd.replink,
    nd.status,
    nd.update, nd.usemedia, nd.media,
    nd.imgvw,
    nd.id, nd.to_uname
  )
  nd.box.add(nd.profile)
  return nd.box
}

# Panel for manage list members, following, followers.,
V.panel.showUserManager = (my) -> {
  var um = {
    node: D.ce("dl"),
    dir: D.ce("input"),
    target: D.ce("input"),
    add: D.ce("button").add(D.ct("Add")),
    del: D.ce("button").add(D.ct("Delete"))
  }
  var curl = U.getURL()
  var onBtn = (event) -> {
    var isAdd = event.target is um.add
    var dir = um.dir.value, target = um.target.value
    if (!dir || !target) return

    var dir_is_list = dir.indexOf("/") >= 0
    var target_is_list = target.indexOf("/") >= 0
    var mode = (target_is_list << 1) | dir_is_list

    switch (mode) {
    case 0:
      switch (dir) {
      case "following":
        API[isAdd ? "follow" : "unfollow"](target, null); break
      case "followers":
        API[isAdd ? "unblock" : "block"](target, null); break
      }
      break
    case 1:
      switch (dir) {
      case "users/muting":
        API[isAdd ? "mute" : "unmute"](target, null); break
      case "users/blocking":
        API[isAdd ? "block" : "unblock"](target, null); break
      case "following/requests":
        API[isAdd ? "requestFollow" : "unrequestFollow"](target, null)
        break
      default: # add user to list
        var arr = dir.split("/"), uname = arr[0], slug = arr[1]
        API[isAdd ? "listing" : "unlisting"](uname, slug, target, null)
        break
      }
      break
    case 2:
      break
    case 3:
      switch (dir) {
      case "lists/subscriptions":
        var arr = target.split("/"), uname = arr[0], slug = arr[1]
        API[isAdd ? "followList" : "unfollowList"](uname, slug, null)
        break
      }
      break
    }
  }
  um.dir.value = curl.path.match(/[^/]+(?:[/][^/]+)?/)
  um.add.addEventListener("click", onBtn)
  um.del.addEventListener("click", onBtn)
  D.q("#side").add(um.node.add(
    D.ce("dt").add(D.ct("destination")),
    D.ce("dd").add(um.dir),
    D.ce("dt").add(D.ct("target")),
    D.ce("dd").add(um.target),
    D.ce("dd").add(um.add, um.del)
  ))
}

# Panel for Manage list
V.panel.showListPanel = (my) -> {
  var list = {
    panel: D.ce("dl"),
    name: D.ce("input"),
    rename: D.ce("input"),
    description: D.ce("textarea"),
    privat: D.ce("input").sa("type", "checkbox"),
    create: D.ce("button").add(D.ct("Create")),
    update: D.ce("button").add(D.ct("Update")),
    del: D.ce("button").add(D.ct("Delete"))
  }
  list.privat.checked = true
  addEventListener("click", (e) -> {
    var node = e.target, mylists = D.q(".listslist.own"), name, desc
    if (!mylists) return
    if (mylists.contains(node) && node.classList.contains("list")) {
      name = D.q.call(node, ".full_name").textContent.split("/")[1]
      desc = D.add.apply(D.cf(),
        [].map.call(D.q.call(node, ".description").childNodes, (e) -> {
          if (e.nodeName.toLowerCase() is "br") return D.ct("\n")
          return e.cloneNode(true)
        })
      ).textContent
      list.name.value = name
      list.description.value = desc
    }
  })
  list.create.addEventListener("click", ->
    var onScs = (xhr) -> {
      var data = JSON.parse(xhr.responseText)
      var ls = API.cc.onGotMyList(data)
      V.main.rendLists(ls["mylists"], my.screen_name)
    }
    API.createList(list.name.value, list.privat.checked ? "private": "public",
                   list.description.value, onScs)
  })
  list.update.addEventListener("click", ->
    var onScs = (xhr) -> {
      var data = JSON.parse(xhr.responseText)
      var ls = API.cc.onGotMyList(data)
      V.main.rendLists(ls["mylists"], my.screen_name)
    }
    API.updateList(my.screen_name, list.name.value, list.rename.value,
                   list.privat.checked ? "private" : "public",
                   list.description.value, onScs)
  })
  list.del.addEventListener("click", ->
    var onScs = (xhr) -> {
      var data = JSON.parse(xhr.responseText)
      var ls = API.cc.onGotMyList(data, true)
      V.main.rendLists(ls["mylists"], my.screen_name)
    }
    API.deleteList(my.screen_name, list.name.value, onScs)
  })
  D.q("#side").add(list.panel.add(
    D.ce("dt").add(D.ct("name")),
    D.ce("dd").add(list.name),
    D.ce("dt").add(D.ct("rename")),
    D.ce("dd").add(list.rename),
    D.ce("dt").add(D.ct("description")),
    D.ce("dd").add(list.description),
    D.ce("dt").add(D.ct("mode")),
    D.ce("dd").add(D.ce("label").add(list.privat, D.ct("private"))),
    D.ce("dd").add(
      list.create,
      list.update,
      list.del
    )
  ))
}
