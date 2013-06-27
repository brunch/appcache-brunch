crypto  = require 'crypto'
fs      = require 'fs'
pathlib = require 'path'


class Walker
  constructor: ->
    @todo = {}
    @walking = false

  add: (path) ->
    @todo[path] = 1
    @walking = true

  del: (path) ->
    delete @todo[path]
    @walking = Object.keys(@todo).length > 0

  readdir: (path, callback) ->
    @add path
    fs.readdir path, (err, filenames) =>
      throw err if err?
      @del path
      callback filenames

  stat: (path, callback) ->
    @add path
    fs.stat path, (err, stats) =>
      throw err if err?
      @del path
      callback stats

  walk: (path, callback) ->
    @readdir path, (filenames) =>
      filenames.forEach (filename) =>
        filePath = pathlib.join path, filename
        @stat filePath, (stats) =>
          if stats.isDirectory()
            @walk filePath, callback
          else
            callback filePath


class Manifest
  constructor: (@config) ->

  brunchPlugin: true

  onCompile: ->
    paths = []
    walker = new Walker
    walker.walk @config.paths.public, (path) =>
      paths.push path unless /[.]appcache$/.test path
      unless walker.walking
        shasums = []
        paths.sort()
        paths.forEach (path) =>
          shasum = crypto.createHash 'sha1'
          s = fs.ReadStream path
          s.on 'data', (data) => shasum.update data
          s.on 'end', =>
            shasums.push shasum.digest 'hex'
            if shasums.length is paths.length
              shasum = crypto.createHash 'sha1'
              shasum.update shasums.sort().join(), 'ascii'
              @write((pathlib.relative @config.paths.public, p for p in paths),
                     shasum.digest 'hex')

  format = (obj) ->
    ("#{k} #{obj[k]}" for k in Object.keys(obj).sort()).join('\n')

  write: (paths, shasum) ->
    fs.writeFileSync pathlib.join(@config.paths.public, 'appcache.appcache'),
    """
      CACHE MANIFEST
      # #{shasum}

      NETWORK:
      #{@config.appcache.network.join('\n')}

      FALLBACK:
      #{format @config.appcache.fallback}

      CACHE:
      #{("#{@config.appcache.staticRoot}/#{p}" for p in paths).join('\n')}
    """


module.exports = Manifest
