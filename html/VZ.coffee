# Render View of Outline (users profile, list profile.,)
V.outline = {}
# tw- path information
V.outline.showSubTitle = (hash) ->
  sub = D.cf()

  for name, i in hash
    dir = D.ce "a"
    dir.href = U.ROOT + hash[0..i].join "/"
    dir.add D.ct decodeURIComponent name
    sub.add D.ct "/" if i
    sub.add dir

  D.q("#subtitle").add(sub)

# Change CSS(text color, background-image) by user settings
V.outline.changeDesign = (user) ->
  rec = /^#[0-9a-f]{6}|/i
  bgimg = /^data:[^]+/.exec(user.profile_background_image_url) ||
    user.profile_background_image_url_https
  color =
    bg: rec.exec("#" + user.profile_background_color)[0]
    bgImg: if user.profile_use_background_image then "url(" + bgimg + ")"
    else "none"
    bgImgRepeat: if user.profile_background_tile then "repeat" else "no-repeat"
    side_fill: rec.exec("#" + user.profile_sidebar_fill_color)[0]
    side_border: rec.exec("#" + user.profile_sidebar_border_color)[0]
    text: rec.exec("#" + user.profile_text_color)[0]
    link: rec.exec("#" + user.profile_link_color)[0]

  style = D.q("#custom-css")
  style.textContent = "html{
    background-color:#{color.bg};
    background-image:#{color.bgImg};
    background-repeat:#{color.bgImgRepeat};
  }
  body{color:#{color.text};}
  a{color:#{color.link};}
  .user-style-bar{
    background-color:#{color.side_fill};
    border-color:#{color.side_border};
  }"

# Step to Render list outline and color
V.outline.showListOutline = (hash, my, mode) ->
  it = V.outline
  url = API.urls.lists.show()() + "?" +
    "owner_screen_name=" + hash[0] + "&slug=" + hash[1]

  onScs = (xhr) ->
    list = JSON.parse(xhr.responseText)
    if mode is undefined then mode = 7
    if list.mode is "private" then mode &= ~4
    mode & 1 && it.changeDesign(list.user)
    mode & 2 && it.showListProfile(list)
    mode & 4 && V.panel.showListFollowPanel(list)
    if xhr instanceof XMLHttpRequest
      LS.state.save("lists_show", list)
      LS.state.save("lists_show_modified", Date.now())

  onErr = (xhr) ->
    V.misc.showXHRError(xhr, D.q("#side"))

  # use cache (history.state) if exist
  state = LS.state.load()
  time = state.lists_show_modified
  usecache = Date.now() - time < 1000 * 60 * 15
  if usecache
    return onScs({responseText:JSON.stringify(state.lists_show)})
  # else use cache (localStorage) if exist
  mylists = API.cc.getMyLists()
  if mylists then for list in mylists
    if list.user.screen_name is hash[0] && list.slug is hash[1]
      return onScs({responseText:JSON.stringify(list)})
  X.get(url, onScs, onErr)

# Render outline of list information
V.outline.showListProfile = (list) ->
  li =
    st: D.ce("dl").sa("class", "list-profile")
    members: D.ce("a").add(D.ct("Members")).
      sa("href", U.ROOT + list.uri.substring(1) + "/members")
    followers: D.ce("a").add(D.ct("Subscribers")).
      sa("href", U.ROOT + list.uri.substring(1) + "/subscribers")
    owner: D.ce("a").add(D.ct(list.user.screen_name)).
      sa("href", U.ROOT + list.user.screen_name)

  if list.mode is "private" then li.st.classList.add("private")
  D.q("#side").add(li.st.add(
    D.ce("dt").add(D.ct("Name")),
    D.ce("dd").sa("class", "name").add(D.ct(T.decodeHTML(list.name))),
    D.ce("dt").add(D.ct("Full Name")),
    D.ce("dd").add(D.tweetize(list.full_name)),
    D.ce("dt").add(D.ct("Description")),
    D.ce("dd").add(D.tweetize(list.description)).sa("class", "description"),
    D.ce("dt").add(li.members),
    D.ce("dd").add(D.ct(list.member_count)),
    D.ce("dt").add(li.followers),
    D.ce("dd").add(D.ct(list.subscriber_count)),
    D.ce("dt").add(D.ct("ID")),
    D.ce("dd").add(D.ct(list.id_str)),
    D.ce("dt").add(D.ct("Mode")),
    D.ce("dd").add(D.ct(list.mode)),
    D.ce("dt").add(D.ct("Since")),
    D.ce("dd").add(D.ct(T.gapTime(new Date(list.created_at)))),
    D.ce("dt").add(D.ct("Owner")),
    D.ce("dd").add(li.owner)
  ))

# Step to Render user profile outline and color
V.outline.showProfileOutline = (screen_name, my, mode) ->
  it = V.outline
  if mode is undefined then mode = 15
  onScs = (xhr) ->
    user = JSON.parse(xhr.responseText)
    if user.id_str is my.id_str then mode &= ~4
    mode & 1 && it.changeDesign(user)
    mode & 2 && it.rendProfileOutline(user)
    mode & 4 && V.panel.showFollowPanel(user)
    mode & 8 && V.panel.showAddListPanel(user, my)

  onErr = (xhr) ->
    # hacking(using API bug) function
    # bug: /blocks/destroy.json returns suspended user's profile
    mode &= ~4
    mode &= ~8
    hack = D.ce("button").add(D.ct("unblock"))
    hack.addEventListener "click", ->
      API.unblock(screen_name, onScs)

    D.q("#side").add(hack)
    V.misc.showXHRError(xhr, D.q("#side"))

  if screen_name[-1..] isnt "@"
    X.get(API.urls.users.show()() + "?screen_name=" + screen_name,
      onScs, onErr)
  else
    X.get(API.urls.users.show()() + "?user_id=" + screen_name.slice(0, -1),
      onScs, onErr)

# Render outline of User Profile
V.outline.rendProfileOutline = (user) ->
  entities = user.entities || {}
  baseurl = U.ROOT + user.screen_name
  p =
    box: D.ce("dl").sa("class", "user-profile")
    icon: D.ce("img").sa("class", "user-icon").sa("alt", user.screen_name).
      sa("src", user.profile_image_url_https.replace("_normal.", "_bigger."))
    icorg: D.ce("a").
      sa("href", user.profile_image_url_https.replace("_normal.", "."))
    tweets: D.ce("a").add(D.ct("Tweets")).
      sa("href", baseurl + "/status")
    favorites: D.ce("a").add(D.ct("Favorites")).
      sa("href", baseurl + "/favorites")
    following: D.ce("a").add(D.ct("Following")).
      sa("href", baseurl + "/following")
    following_timeline: D.ce("a").add(D.ct("Tweets")).
      sa("href", baseurl + "/following/tweets")
    followers: D.ce("a").add(D.ct("Followers")).
      sa("href", baseurl + "/followers")
    lists: D.ce("a").add(D.ct("Lists")).
      sa("href", baseurl + "/lists")
    listsub: D.ce("a").add(D.ct("Subscriptions")).
      sa("href", baseurl + "/lists/subscriptions")
    listed: D.ce("a").add(D.ct("Listed")).
      sa("href", baseurl + "/lists/memberships")

  if user.protected then p.box.classList.add("protected")
  if user.verified then p.box.classList.add("verified")
  D.q("#side").add(p.box.add(
    D.ce("dt").add(D.ct("Screen Name")),
    D.ce("dd").add(D.ct(user.screen_name)),
    D.ce("dt").add(if user.profile_banner_url then D.ce("a").
      sa("href", user.profile_banner_url + "/web").add(D.ct("Icon"))
      else D.ct("Icon")),
    D.ce("dd").add(p.icorg.add(p.icon)),
    D.ce("dt").add(D.ct("Name")),
    D.ce("dd").add(D.ct(T.decodeHTML(user.name))),
    D.ce("dt").add(D.ct("Location")),
    D.ce("dd").add(D.ct(T.decodeHTML(user.location))),
    D.ce("dt").add(D.ct("Web")),
    D.ce("dd").add(D.tweetize(user.url, entities.url)),
    D.ce("dt").add(D.ct("Bio")),
    D.ce("dd").add(D.tweetize(user.description, entities.description)).
      sa("class", "description"),
    D.ce("dt").add(p.tweets),
    D.ce("dd").add(D.ct(user.statuses_count)),
    D.ce("dt").add(p.favorites),
    D.ce("dd").add(D.ct(user.favourites_count)),
    D.ce("dt").add(p.following, D.ct("/"), p.following_timeline),
    D.ce("dd").add(D.ct(user.friends_count)),
    D.ce("dt").add(p.followers),
    D.ce("dd").add(D.ct(user.followers_count)),
    D.ce("dt").add(p.listed),
    D.ce("dd").add(D.ct(user.listed_count)),
    D.ce("dt").add(p.lists),
    D.ce("dt").add(p.listsub),
    D.ce("dt").add(D.ct("ID")),
    D.ce("dd").add(D.ct(user.id_str)),
    D.ce("dt").add(D.ct("Protected")),
    D.ce("dd").add(D.ct(user.protected)),
    D.ce("dt").add(D.ct("Time Zone")),
    D.ce("dd").add(D.ct(user.time_zone)),
    D.ce("dt").add(D.ct("Language")),
    D.ce("dd").add(D.ct(user.lang)),
    D.ce("dt").add(D.ct("Since")),
    D.ce("dd").add(D.ct(new Date(user.created_at).toLocaleString()))
  ))

V.outline.showSearchPanel = (query) ->
  nd =
    search: D.ce("input").sa("list", "saved_searches")
    go: D.ce("button").add(D.ct("Search"))
    save: D.ce("button").add(D.ct("Save"))
    list: D.ce("datalist").sa("id", "saved_searches")
    del: D.ce("button").add(D.ct("Delete"))

  nd.search.value = query || ""

  # vars/functions
  sslist = []
  newSSNode = (item) ->
    D.ce("option").sa("class", "search_item").sa("title", item.id_str).
      sa("value", item.query).add(D.ct(item.query))

  updSSNodes = ->
    items = sslist.map(newSSNode).reverse()
    if items.length then D.add.apply(D.empty(nd.list), items)

  # GET saved_searches
  onScs = (xhr) ->
    data = JSON.parse(xhr.responseText)
    sslist = data
    updSSNodes()

  ls_svs = API.cc.getSvs()
  if ls_svs
    onScs({responseText:JSON.stringify(ls_svs)})
  else
    X.get(API.urls.search.saved.list()(), onScs, null)

  # add event listeners

  # [Save]
  nd.save.addEventListener "click", ->
    X.post API.urls.search.saved.create()(), "query=" + nd.search.value,
      (xhr) ->
        data = JSON.parse(xhr.responseText)
        sslist.push(data)
        LS.save("saved_searches", sslist)
        updSSNodes()

  # [Delete]
  nd.del.addEventListener "click", ->
    sslist.some (item, i) ->
      istr = nd.search.value
      if istr is item.query
        return X.post API.urls.search.saved.destroy()(item.id_str), "", ->
          sslist.splice(i, 1)
          LS.save("saved_searches", sslist)
          updSSNodes()

  # [Search]
  nd.go.addEventListener "click", ->
    location.href = U.ROOT + "search/" + encodeURIComponent(nd.search.value)

  nd.search.addEventListener "keypress", (e) ->
    if e.keyCode is 13 then D.ev(nd.go, "click")

  # render
  D.q("#side").add(
    D.ce("dl").add(
      D.ce("dt").add(D.ct("search")),
      D.ce("dd").add(nd.search, nd.list, nd.go, nd.save, nd.del)
    )
  )

# main
do ->
  ls = LS.load()
  my = ls["credentials"]
  editDOM = ->
    V.init.initNode(my)
    V.main.showPage(my)
  API.urls.init()
  if document.readyState is "complete" then editDOM()
  else addEventListener "DOMContentLoaded", -> editDOM()
  if !API.cc.getCredentials()
    X.get API.urls.account.verify_credentials()(), null, null
  if !API.cc.getConfiguration()
    X.get API.urls.help.configuration()(), null, null
