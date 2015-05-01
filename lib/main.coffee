{ EOL } = require 'os'

{ resolve, dirname } = require 'path'

{ createWriteStream, writeFileSync, existsSync } = require 'fs'

{ sync: mkdirSync } = require 'mkdirp'

module.exports = (file, next) ->

  if typeof file isnt "string" then return next new Error(

    "invalid log file: #{file}"

  )

  logfile = resolve file

  dir = dirname logfile

  if not existsSync dir then  mkdirSync dir

  if not existsSync logfile then writeFileSync logfile, ''

  stream = createWriteStream logfile, { flags: 'a' }

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
