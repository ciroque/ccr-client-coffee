"use strict";

window.LogLevel = class LogLevel
  @ALL      = 9999
  @NONE     = -1
  @ERROR    = 0
  @WARN     = 1
  @INFO     = 2
  @DEBUG    = 3

window.Logger = class Logger
  LogLevels = ['ERROR', 'WARN', 'INFO', 'DEBUG'];

  constructor: (opts = {}) ->
    @opts = AppTools.merge({ level: LogLevel.DEBUG, sink: console }, opts)

  setLogLevel: (level) ->
    @opts.level = level

  write: (level, msg) ->
    message = new Date().toISOString() + '\t' + LogLevels[level] + '\t' + msg;
    this.opts.sink.log(message) if level <= @opts.level

  debug: (msg) ->
    this.write(LogLevel.DEBUG, msg)

  error: (msg) ->
    this.write(LogLevel.ERROR, msg)

  info: (msg) ->
    this.write(LogLevel.INFO, msg)

  warn: (msg) ->
    this.write(LogLevel.WARN, msg)
