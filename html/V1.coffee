# Objects for View
V = {}

# Page Init Functions
V.init = {}

V.init.CSS = '
  html, body, dl, dt, dd, ul, ol, li, h1, h2, h3, h4, h5, h6, p {
    margin: 0;
    padding: 0;
  }
  html {
    min-height: 100%;
    background-attachment: fixed;
    background-repeat: no-repeat;
  }
  body {
    max-width: 750px;
    margin: 0 auto;
    padding: 1ex;
    line-height: 1.6;
    font-family: monospace;
    font-size: 14px;
  }
  textarea {
    display: block;
    width: 100%;
    height: 7em;
  }
  button {
    line-height: 1.1;
  }
  dl {
    padding: 2ex;
  }
  dl dl {
    padding: 0;
  }
  dt {
    font-weight: bold;
  }
  dd {
    margin: 0 0 1em 1em;
  }
  table { border-collapse: collapse; font-size: inherit; }
  td, th { padding: .5ex; border: 1px solid; text-align: left; }
  a {
    text-decoration: none;
  }
  #header {
    border-width: 0 0 1px 0;
    border-style: solid;
  }
  #globalbar {
    border-width: 0 0 1px 0;
    border-style: solid;
    font-size: small;
  }
  #globalbar > li {
    display: inline-block;
    margin-right: 2ex;
  }
  #globalbar li > ul {
    display: none;
  }
  #globalbar li:hover > ul {
    display: block;
    position: absolute;
    padding: 1ex;
    border: 1px solid;
    background: hsla(0,0%,100%,.95);
    color: hsla(0,0%,80%,.95);
    list-style: none;
    z-index: 1;
  }
  #globalbar li li+li {
    border-top: 1px solid;
  }
  #subtitle {
    font-size: 3ex;
    padding: 1ex;
    border-width: 0 0 1px 0;
    border-style: solid;
  }
  #subaction {
    line-height: 1;
    color: ButtonText;
    background-color: ButtonFace;
  }
  #subaction a {
    display: inline-block;
    margin-left: 1ex;
  }
  #content, #side {
    vertical-align: top;
  }
  #content {
    display: table-cell;
    width: 500px;
    max-width: 500px;
    word-wrap: break-word;
  }
  #side {
    display: table-cell;
    box-sizing: border-box;
    width: 250px;
    max-width: 250px;
    font-size: smaller;
    border-width: 0 0 0 1px;
    border-style: solid;
    word-wrap: break-word;
  }
  #status_section {
  }
  #status_profile {
    box-sizing: border-box;
    max-width: 500px;
    border: 0 !important;
  }
  #status {
    width: 100%;
    height: 7em;
  }
  #in_reply_to_status_id, #in_reply_to_screen_name {
    display: none;
  }
  #status_media_preview {
    display: none;
    margin-top: 1ex;
  }
  #status_media_preview.use_media {
    display: block;
  }
  #status_media_preview::after {
    content: "";
    display: block;
    clear: both;
  }
  #status_media_preview li {
    float: left;
    display: block;
    margin: 0 9px 9px 0;
    box-shadow: 1px 1px 3px #999;
  }
  #status_media_preview li .media_image {
    display: block;
    width: 48px;
    height: 48px;
  }
  #status_media {
    max-width: 50%;
  }
  #reply_target_link.replying {
    display: inline;
  }
  #reply_target_link {
    display: none;
  }
  #status_log {
    width: 100%;
    max-width: 500px;
    word-wrap: break-word;
  }
  #status_log .tweet {
    border: none;
    border-top: 1px solid silver;
  }
  #timeline {
  }
  #users {
  }
  #cursor {
    display: table;
    width: 100%;
  }
  #cursor li {
    display: table-cell;
    text-align: center;
  }
  .cursor_next {
  }
  .cursor_prev {
  }
  .user-style-bar {
    border-color: transparent;
  }
  a.maybe_shorten_url {
  }
  a.expanded_tco_url {
  }
  a.expanded_url {
    text-decoration: underline;
  }
  #xhr-statuses { position: fixed; top: 0; left: 0; z-index: 1; }
  .xhr-state { font-size:xx-small; }
  .xhr-state.loading { position:absolute; background: gray; color: white; }
  .xhr-state.done.success { background: white; color: gray; }
  .xhr-state.done.failed { background: red; color: white; }
  #api-status { background: #fdfdfd; }
  #api-status * { border-color: #ccc; }
  #api-status :not(.active) * { opacity: .3; }
  #status_profile,
  #subaction a,
  .list,
  .user,
  .tweet {
    background-color: #fdfdfd;
  }
  #status_profile,
  .list,
  .user,
  .tweet {
    position: relative;
    list-style: none;
    min-height: 48px;
    padding: 1ex 1ex 1ex 60px;
    border-bottom: 1px solid silver;
  }
  .tweet.focus {
    background-color: #fc0;
  }
  .tweet .text,
  .user-profile .description,
  .list-profile .description,
  .user .description,
  .list .description {
    white-space: pre-wrap;
  }
  .user-profile.verified > dd:first-of-type::before,
  .user.verified .name::before,
  .tweet.verified .name::before {
    content: "verified";
    font-weight: normal;
    vertical-align: middle;
    font-size: xx-small;
    padding: 0.5ex;
    background-color: #3cf;
    color: white;
    margin-right: 1ex;
  }
  .user-profile.protected > dd:first-of-type::after,
  .user.protected .name::after,
  .tweet.protected .name::after,
  .list-profile.private dd:first-of-type::after,
  .list.private .name::after {
    content: "protected";
    font-weight: normal;
    vertical-align: middle;
    font-size: xx-small;
    padding: 0.5ex;
    background-color: gray;
    color: white;
    margin-left: 1ex;
  }
  .list-profile.private > dd:first-of-type::after,
  .list.private .name::after {
    content: "private";
  }
  #status_profile .name,
  #status_profile .in_reply_to,
  .list .name,
  .user .name,
  .tweet .name,
  .tweet .in_reply_to {
    margin-left: 1ex;
  }
  #status_profile .name,
  .list .name, .list .name *, .list .meta, .list .meta *,
  .user .name, .user .name *, .user .meta, .user .meta *,
  .tweet .name, .tweet .name *, .tweet .meta, .tweet .meta * {
    color: #999 !important;
  }
  .list .meta,
  .user .meta,
  .tweet .meta {
    font-size: smaller;
  }
  .list .meta a,
  .user .meta a,
  .tweet .meta a {
    color: inherit;
  }
  .tweet.retweet::before {
    content: "RT";
    margin-right: 0.5ex;
    padding: 0.5ex;
    background-color: gray;
    color: white;
    font-weight: bold;
  }
  #status_profile .screen_name,
  .list .full_name,
  .user .screen_name,
  .tweet .screen_name {
    font-weight: bold;
  }
  #status_profile .in_reply_to,
  .tweet .in_reply_to {
    font-size: smaller;
  }
  #status_profile .user-icon,
  .list .user-icon,
  .user .user-icon,
  .tweet .user-icon {
    position: absolute;
    left: 1ex;
    top: 1ex;
    width: 48px;
    height: 48px;
  }
  .meta .source:not(:empty)::before { content: " via "; }
  .meta .geo:not(:empty)::before { content: " from "; }
  .meta .retweeter:not(:empty)::before { content: " by "; }
  .user-profile .user-icon {
    width: 73px;
    height: 73px;
  }
  .twimgs li {
    list-style: inside;
  }
  [role=button][aria-pressed=mixed]::before {
    content: "\\ff1f";
    font-weight: bold;
  }
  [role=button][aria-pressed=true]::before {
    content: "\\2714";
  }
  img.emoji {
    width: 1em;
  }
'

# Clear all node and set new one
V.init.initNode = (my) -> {
  D.add.call(D.empty(document),
    document.implementation.createDocumentType("html", "", ""),
    D.ce("html").sa("lang", "und").add(
      D.ce("head"),
      D.ce("body")
    )
  )
  D.q("head").add(
    D.ce("meta").sa("charset", "utf-8"),
    D.ce("style").add(D.ct(V.init.CSS)),
    D.ce("style").sa("id", "custom-css"),
    D.ce("title").add(D.ct("tw-"))
  )
  D.q("body").add(
    D.ce("ul").sa("id", "xhr-statuses"),
    D.ce("header").sa("id", "header").sa("class", "user-style-bar").add(
      D.ce("ul").sa("id", "globalbar").sa("class", "user-style-bar"),
      D.ce("div").sa("id", "status_section").sa("class", "user-style-bar"),
      D.ce("ol").sa("id", "status_log")
    ),
    D.ce("section").sa("id", "content").sa("class", "user-style-bar").add(
      D.ce("h1").sa("id", "subtitle").sa("class", "user-style-bar"),
      D.ce("div").sa("id", "subaction").add(
        D.ce("div").sa("id", "subaction-inner-1"),
        D.ce("div").sa("id", "subaction-inner-2")
      ),
      D.ce("article").sa("id", "main"),
      D.ce("ul").sa("id", "cursor")
    ),
    D.ce("aside").sa("id", "side").sa("class", "user-style-bar")
  )
  D.q("#globalbar").add(V.panel.newGlobalBar(my))
  D.q("#status_section").add(V.panel.newTweetBox(my))
}

# Functions of Render main content
V.main = {}

# Show Content by path in URL
V.main.showPage = (my) -> {
  var it = V.main
  var curl = U.getURL()
  var path = curl.path
  var hash = path.split("/")
  var q = T.strQuery(curl.query)

  D.q("title").textContent = "tw-/" + path
  V.outline.showSubTitle(hash)

  switch (hash.length) {
  case 1:
    it.showPage.on1(hash, q, my)
    break
  case 2:
    it.showPage.on2(hash, q, my)
    break
  case 3:
    it.showPage.on3(hash, q, my)
    break
  default:
    it.showPage.on3(hash, q, my)
    break
  }
}
V.main.showPage.on1 = (hash, q, my) -> {
  var it = V.main
  switch (hash[0]) {
  case "login":
    it.showLoginUI(q)
    break
  case "settings":
    D.q("#main").add(it.newSettings(my))
    break
  case "users":
    D.q("#main").add(it.newUsers(my))
    break
  case "lists":
    it.showLists(API.urls.lists.all()() + "?" + q +
      "&reverse=true&cursor=-1", my)
    V.panel.showListPanel(my)
    break
  case "inbox":
    it.showTL(API.urls.d.inbox()() + "?" + q, my)
    break
  case "sent":
    it.showTL(API.urls.d.sent()() + "?" + q, my)
    break
  case "favorites":
    it.showTL(API.urls.favorites.list()() + "?" + q, my)
    break
  case "following":
    it.showUsersByIds(API.urls.users.friends_ids()() + "?" + q +
      "&stringify_ids=true", my)
    break
  case "followers":
    it.showUsersByIds(API.urls.users.followers_ids()() + "?" + q +
      "&stringify_ids=true", my)
    break
  case "mentions":
    it.showTL(API.urls.timeline.mentions()() + "?" + q, my)
    break
  case "":
    it.showTL(API.urls.timeline.home()() + "?" + q, my)
    break
  default:
    it.showTL(API.urls.timeline.user()() + "?" + q +
      "&" + T.userQryStr(hash[0]), my)
    V.outline.showProfileOutline(hash[0], my)
  }
}

V.main.showPage.on2 = (hash, q, my) -> {
  var it = V.main
  if (hash[0] is "following") switch (hash[1]) {
  case "requests":
    it.showUsersByIds(API.urls.users.outgoing()() + "?" + q, my)
    break

  } else if (hash[0] is "followers") switch (hash[1]) {
  case "requests":
    it.showUsersByIds(API.urls.users.incoming()() + "?" + q, my, 1)
    break

  } else if (hash[0] is "lists") switch (hash[1]) {
  case "ownerships":
    it.showLists(API.urls.lists.list()() + "?" + q, my)
    V.panel.showListPanel(my)
    break
  case "memberships":
    it.showLists(API.urls.lists.listed()() + "?" + q, my)
    break
  case "subscriptions":
    it.showLists(API.urls.lists.subscriptions()() + "?" + q, my)
    V.panel.showUserManager(my)
    break

  } else if (hash[0] is "settings") switch (hash[1]) {
  case "profile": it.settingProfile(my); break
  case "options": it.settingOptions(); break
  case "follow": it.settingFollow(my); break
  case "design": it.customizeDesign(my); break
  case "account": it.settingAccount(my); break
  case "api": it.testAPI(my); break

  } else if (hash[0] is "search") {
    it.showTL(API.urls.search.tweets()() + "?q=" + hash[1] + "&" + q, my)
    V.outline.showSearchPanel(decodeURIComponent(hash[1]))

  } else if (hash[0] is "direct_messages") switch (hash[1]) {
  default:
    it.showTL(API.urls.d.show()() + "?id=" + hash[1] + "&" + q, my)

  } else if (hash[0] is "users") switch (hash[1]) {
  case "muting":
    it.showUsersByIds(API.urls.mutes.ids()() + "?" + q +
      "&stringify_ids=true", my)
    break
  case "blocking":
    it.showUsersByIds(API.urls.blocking.ids()() + "?" + q +
      "&stringify_ids=true", my)
    break

  } else switch (hash[1]) {
  case "status": case "statuses":
    it.showTL(API.urls.timeline.user()() + "?" + q +
      "&screen_name=" + hash[0], my)
    break
  case "favorites":
    it.showTL(API.urls.favorites.list()() + "?" + q +
      "&screen_name=" + hash[0], my)
    V.outline.showProfileOutline(hash[0], my, 3)
    break
  case "following":
    it.showUsersByIds(API.urls.users.friends_ids()() + "?" + q +
      "&screen_name=" + hash[0] + "&stringify_ids=true", my)
    V.outline.showProfileOutline(hash[0], my, 3)
    break
  case "followers":
    it.showUsersByIds(API.urls.users.followers_ids()() + "?" + q +
      "&screen_name=" + hash[0] + "&stringify_ids=true", my)
    V.outline.showProfileOutline(hash[0], my, 3)
    break
  case "lists":
    it.showLists(API.urls.lists.all()() + "?" + q +
      "&screen_name=" + hash[0] + "&reverse=true", my)
    V.outline.showProfileOutline(hash[0], my, 3)
    break
  default:
    if (hash[0] is "status" || hash[0] is "statuses") {
      it.showTL(API.urls.tweet.get()(hash[1]) + "?" + q, my)
    } else {
      it.showTL(API.urls.lists.tweets()() + "?" + q +
        "&owner_screen_name=" + hash[0] +
        "&slug=" + hash[1] +
        "&include_rts=false", my)
      V.outline.showListOutline(hash, my)
    }
  }
}

V.main.showPage.on3 = (hash, q, my) -> {
  var it = V.main
  if (hash[1] is "lists") switch (hash[2]) {
  case "memberships":
    it.showLists(API.urls.lists.listed()() + "?" + q +
      "&screen_name=" + hash[0], my)
    V.outline.showProfileOutline(hash[0], my, 3)
    break
  case "subscriptions":
    it.showLists(API.urls.lists.subscriptions()() + "?" + q +
      "&screen_name=" + hash[0], my)
    V.outline.showProfileOutline(hash[0], my, 3)
    break

  } else if (hash[0] is "search" && hash[1] is "users") {
    it.showUsers(API.urls.search.users()() + "?q=" + hash[2] + "&" + q, my, 4)

  } else if (hash[0] is "settings" && hash[1] is "api") switch (hash[2]) {
  case "status":
    X.get(API.urls.account.rate_limit_status()(),
      it.showAPIStatus, V.misc.showXHRError)
    break

  } else switch (hash[2]) {
  case "tweets": case "timeline":
    if (hash[1] is "following") {
      it.showTL("/1/statuses/following_timeline.json?" + q +
        "&include_entities=true&screen_name=" + hash[0], my)
      V.outline.showProfileOutline(hash[0], my, 3)
    } else {
      it.showTL(API.urls.lists.tweets()() + "?" + q +
        "&owner_screen_name=" + hash[0] +
        "&slug=" + hash[1], my)
    }
    break
  case "members":
    it.showUsers(API.urls.lists.users.members()() + "?" + q +
      "&owner_screen_name=" + hash[0] + "&slug=" + hash[1], my)
    V.outline.showListOutline(hash, my, 3)
    break
  case "subscribers":
    it.showUsers(API.urls.lists.users.subscribers()() + "?" + q +
      "&owner_screen_name=" + hash[0] + "&slug=" + hash[1], my)
    V.outline.showListOutline(hash, my, 3)
    break
  default:
    if (hash[1] is "status" || hash[1] is "statuses") {
      it.showTL(API.urls.tweet.get()(hash[2]) + "?" + q, my)
      V.outline.showProfileOutline(hash[0], my, 1)
    }
  }
}
