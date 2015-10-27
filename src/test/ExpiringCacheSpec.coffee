"use strict"

describe 'ExpiringCache', ->
  KEY = "KEY"
  UNKEY = "UNKEY"
  VALUE = "VALUE"
  @expiringCache = null

  beforeEach(() ->
    @expiringCache = new ExpiringCache()
    @expiringCache.put("DEFAULT", "DEFAULT_VALUE", 1440)
  )

#  afterEach(() -> console.log(JSON.stringify(@expiringCache.getStats())) if @expiringCache)

  it 'returns null when a key is not found', ->
    item = @expiringCache.get("some_invalid_key")
    expect(item).toBe null

  it 'allows an item to be added', ->
    @expiringCache.put(KEY, VALUE, 60)
    expect(@expiringCache.getLength()).toBe 2

  it 'updates an existing item', ->
    newValue = VALUE + ":EDITED"
    @expiringCache.put(KEY, newValue, 60)
    expect(@expiringCache.getLength()).toBe 2
    expect(@expiringCache.get(KEY)).toBe newValue

  it 'returns null when the item has expired', ->
    @expiringCache.put(KEY, VALUE, 1)
    expect(@expiringCache.get(KEY)).toBe(VALUE)
    Utils.sleep(1001)
    expect(@expiringCache.get(KEY)).toBe null

  it 'increments the CacheStats::cacheAttempts property', ->
    @expiringCache.put(KEY, VALUE, 15)
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheAttempts).toBe 1
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheAttempts).toBe 2
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheAttempts).toBe 6

  it 'increments the CacheStats::cacheHits property', ->
    @expiringCache.put(KEY, VALUE, 15)
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheHits).toBe 1
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheHits).toBe 2
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheHits).toBe 6

  it 'increments the CacheStats::cacheMisses property', ->
    @expiringCache.put(KEY, VALUE, 15)
    @expiringCache.get(UNKEY)
    expect(@expiringCache.getStats().cacheMisses).toBe 1
    @expiringCache.get(UNKEY)
    expect(@expiringCache.getStats().cacheMisses).toBe 2
    @expiringCache.get(UNKEY)
    @expiringCache.get(UNKEY)
    @expiringCache.get(UNKEY)
    @expiringCache.get(UNKEY)
    expect(@expiringCache.getStats().cacheMisses).toBe 6

  it 'increments the CacheStats::cacheExpiries property', ->
    @expiringCache.put(KEY, VALUE, 0)
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheExpiries).toBe 1
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheExpiries).toBe 1
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    @expiringCache.get(KEY)
    expect(@expiringCache.getStats().cacheExpiries).toBe 1
    expect(@expiringCache.getStats().cacheMisses).toBe 5
