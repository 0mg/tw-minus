# tw-minus

A Twitter client.

* author: [0mg](http://0mg.github.io/)
* source code: https://github.com/0mg/tw-minus.git

## Get ready

* Twitter: create [Twitter app](https://apps.twitter.com/), get below.
    * consumer_key = {MYTWITTERAPPCONSUMERKEY}
    * consumer_secret = {MYTWITTERAPPCONSUMERSECRET}

There are 2 installation types.

## Install | for Heroku

* install [Git](http://www.git-scm.com/). --*git.exe*
* sign up [Heroku](https://www.heroku.com/). --*[heroku.exe](https://toolbelt.heroku.com/)*

1. Heroku: create Heroku app.
    * app name = {myapp}
2. Heroku: set below ["Config Vars"](https://devcenter.heroku.com/articles/config-vars) for {myapp}.
    * URL = https://{myapp}.herokuapp.com
    * consumer_key = {MYTWITTERAPPCONSUMERKEY}
    * consumer_secret = {MYTWITTERAPPCONSUMERSECRET}
3. Git: `git clone https://github.com/0mg/tw-minus.git`
4. Git: `git push git@heroku.com:{myapp}.git +master`
5. Web browser: https://{myapp}.herokuapp.com/
6. **DONE**

```bat
heroku create {myapp}
heroku config:set URL=https://{myapp}.herokuapp.com consumer_key={MYTWITTERAPPCONSUMERKEY} consumer_secret={MYTWITTERAPPCONSUMERSECRET} --app {myapp}
git clone https://github.com/0mg/tw-minus.git
cd tw-minus
git push git@heroku.com:{myapp}.git +master
heroku apps:open --app {myapp}
```

## Install | for localhost

* install [Node.js](http://nodejs.org/) --*node.exe*

1. OS: expand [source](https://github.com/0mg/tw-minus/archive/master.zip).
2. OS: set below environment variables.
    * consumer_key = {MYTWITTERAPPCONSUMERKEY}
    * consumer_secret = {MYTWITTERAPPCONSUMERSECRET}
3. Node.js: `node index.js`
4. Web browser: https://localhost:3000/
5. **DONE**

That `node_index_js.cmd` is useful to start tw-minus with set *local* environment variables.

```bat
@echo off
setlocal
set consumer_key={MYTWITTERAPPCONSUMERKEY}
set consumer_secret={MYTWITTERAPPCONSUMERSECRET}
node index.js
endlocal
```

## Files info

### Heroku loads

* Procfile *--like a bootstrap code*
* package.json *--Heroku installs [npm](https://www.npmjs.org/) modules listed in `package.json` to {myapp} server automatic.*

### Node.js loads

* index.js *--Web server*

Other files are be loaded via index.js.

ex: index.js responds below to Web browsers.

* html/
    * index.html
    * tw-minus.user.js *--usable standalone UserJS as well*
    * tw-minus-patch.js
    * favicon.ico
