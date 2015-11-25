"use strict"

window.ExpiringCache = class ExpiringCache
  class CacheStats
    constructor: () ->
      @cacheAttempts = 0
      @cacheHits = 0
      @cacheMisses = 0
      @cacheExpiries = 0

  constructor: () ->
    @stats = new CacheStats
    @items = {}

  put: (key, value, ttl) ->
    item = {v: value, expires: new Date().getTime() + (ttl * 1000)}
    @items[key] = item
    @

  getLength: () -> Object.keys(@items).length

  get: (key) ->
    @stats.cacheAttempts += 1
    if(@items[key])
      found = @items[key]
      nowMillis = new Date().getTime()
      if(found.expires <= nowMillis)
        @stats.cacheExpiries += 1
        delete @items[key]
        null
      else
        @stats.cacheHits += 1
        found.v
    else
      @stats.cacheMisses += 1
      null

  getStats: () ->
    clone = (o) ->
      c = {}
      for k of o
        c[k] = o[k]
      c
    clone(@stats)
