{ EOL } = require 'os'

{ resolve, dirname } = require 'path'

{ createWriteStream, writeFileSync, existsSync } = require 'fs'

{ sync: mkdirSync } = require 'mkdirp'

module.exports = (options, next) ->

  { file, stream } = options

  logstream = (f) ->

    if typeof f is undefined then file = "log"

    if typeof f isnt "string" then return next new Error(

      "invalid log file: #{f}"

    )

    lf = resolve f

    dir = dirname lf

    if not existsSync dir then  mkdirSync dir

    if not existsSync lf then writeFileSync lf, ''

    createWriteStream lf, { flags: 'a' }

  stream ?= logstream file

  write = (level, args) ->

    message = [level, (new Date).toString()]

    args.map (arg) ->

      if typeof arg isnt "string"

        arg = arg?.toString() or JSON.stringify arg

      message.push arg

    message = message.join " - "

    stream.write "#{message}#{EOL}"

  Object.defineProperty @, "console", value:

    log: (args...) -> write "log", args

    info: (args...) -> write "info", args

    warning: (args...) -> write "warning", args

    error: (args...) -> write "error", args

  next null
