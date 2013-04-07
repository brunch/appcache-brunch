# appcache-brunch
Adds [brunch](http://brunch.io) compilation time to HTML5 appcache file.

If `appcache.appcache` exists in any of your `assets/` directory,
plugin will add build time on bottom of the file after every build.

## Usage
Install the plugin via npm with `npm install --save appcache-brunch`.

Or, do manual install:

* Add `"appcache-brunch": "x.y.z"` to `package.json` of your brunch app.
  Pick a plugin version that corresponds to your minor (y) brunch version.
* If you want to use git version of plugin, add
`"appcache-brunch": "git+ssh://git@github.com:brunch/appcache-brunch.git"`.
