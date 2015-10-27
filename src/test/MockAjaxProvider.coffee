"use strict"

window.MockAjaxProvider = class MockAjaxProvider
  constructor: (@logger, @opts = { results: [], callError: null }) ->

  ajax: (query) ->
    @logger.info(JSON.stringify(query))
    if(@opts.callError)
      query.fail(@opts.callError)
    else
      query.success(@opts.results)
