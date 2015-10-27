"use strict"

window.CentralConfigurationRepositoryClient = class CentralConfigurationRepositoryClient
  constructor: (@logger, opts = {}) ->
    @opts = AppTools.merge({ lib: $, ccrService: { protocol: 'http', host: 'localhost', port: 35487 }}, opts)
    @cache = new ExpiringCache()

  buildWebQuery: (url, success = null, failure = null) ->
    {
    lib: @opts.lib,
    url: "#{@opts.ccrService.protocol}://#{@opts.ccrService.host}:#{@opts.ccrService.port}/ccr/settings/#{url}",
    logger: @logger,
    success: (result) ->
      success(result) if success?
      @logger.debug("ServiceClient::AjaxCall to #{url} succeeded")
    fail: (error) ->
      failure(error) if failure?
      @logger.error("ServiceClient::AjaxCall to #{url} failed: #{error}")
    execute: (data = null, crossDomain = false, contentType = null) ->
      @contentType = contentType if contentType
      @data = data if data
      @lib.ajax(@)
    }

  retrieveEnvironments: (success = null, failure = null) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveEnvironments')
    @buildWebQuery(
      '',
      success,
      failure
    ).execute()

  retrieveApplications: (environment, success = null, failure = null) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveApplications')
    @buildWebQuery(
      "#{environment}",
      success,
      failure
    ).execute()

  retrieveScopes: (environment, application, success = null, failure = null) ->
    @logger.debug("CentralConfigurationRepositoryClient::retrieveScopes('#{environment}', '#{application}')")
    @buildWebQuery(
      "#{environment}/#{application}",
      success,
      failure
    ).execute()

  retrieveSettings: (environment, application, scope, success = null, failure = null) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveSettings')
    @buildWebQuery(
      "#{environment}/#{application}/#{scope}",
      success,
      failure
    ).execute()

  retrieveConfigurations: (environment, application, scope, setting, sourceId = null, success = null, failure = null) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveConfigurations')

    buildQueryPath = (includeSourceId = false) ->
      base = "#{environment}/#{application}/#{scope}/#{setting}"
      if sourceId && includeSourceId
        base + "?sourceId=#{sourceId}"
      else
        base

    cache = @cache

    successHandler = (result) ->
      cfg = result.configuration[0]
      cache.put(buildQueryPath(), cfg, cfg.temporality.ttl)
      success(result) if success?

    webQuery = @buildWebQuery(
      "#{buildQueryPath(true)}",
      successHandler,
      failure,
    )

    path = buildQueryPath()
    cfg = @cache.get(path)

    if cfg
      @logger.debug("CentralConfigurationRepositoryClient::retrieveConfigurations #{path} found in cache")
      webQuery.success({ configuration: [ cfg ], cacheHit: true })

    else
      webQuery.execute()
