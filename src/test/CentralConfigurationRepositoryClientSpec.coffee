"use strict"

describe "CentralConfigurationRepositoryClient", ->
  @logSnk = null
  @logger = null
  @client = null

  TODAY = new Date()
  YESTERDAY = new Date().setDate(TODAY.getDate() - 1)
  TOMORROW = new Date().setDate(TODAY.getDate() + 1)
  URL = 'BOO'
  EVT_SUCCESS = () -> {}
  EVT_FAILURE = () -> {}
  ERROR_MSG = "THIS IS A FAILURE MESSAGE"
  ENVIRONMENTS = ['PROD', 'QA', 'DEV', 'DEFAULT']
  APPLICATIONS = ['WEB', 'DESKTOP', 'SERVICE']
  SCOPES = ['LOGGING', 'BL']
  SETTINGS = ['LOGFILENAME', 'LOGLEVEL', 'ROLLINTERVAL']
  CONFIGURATIONS = {
    configuration: [{
      key: {
        environment: ENVIRONMENTS[0],
        application: APPLICATIONS[0],
        scope: SCOPES[0],
        setting: SETTINGS[0],
        sourceId: "BOOM"
      },
      value: 'YAYHOO',
      temporality: {
        effectiveAt: YESTERDAY,
        expiresAt: TOMORROW,
        ttl: 1
      }
    }]
  }

  beforeEach(() ->
    @logSnk = new TestLoggingSink()
    @logger = new Logger({level: LogLevel.ALL, sink: @logSnk})
    @client = new CentralConfigurationRepositoryClient(@logger)
  )

  describe 'buildWebQuery', ->
    it 'builds a web query object', ->
      webQuery = @client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE)
      expect(webQuery.lib).toBe $
      expect(webQuery.url).toContain(URL)
      expect(webQuery.logger).toBe @logger
      expect(webQuery.success).toBeDefined()
      expect(webQuery.fail).toBeDefined()
      expect(webQuery.execute).toBeDefined()

    it 'calls the provided success handler with the appropriate arguments', ->
      successCalled = false
      errorCalled = false
      success = (result) -> expect(result).toBe ENVIRONMENTS; successCalled = true
      failure = (error) -> fail("error handler should not have been called!"); errorCalled = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {results: ENVIRONMENTS})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})
      webQuery = client.buildWebQuery(URL, success, failure)

      webQuery.execute()
      expect(successCalled).toBe true
      expect(errorCalled).toBe false
      expect(@logSnk.getEventCount()).toBe 2
      expect(@logSnk.getEvents()[1]).toContain("ServiceClient::AjaxCall to #{URL} succeeded")

    it 'calls the provided error handler with the appropriate arguments', ->
      successCalled = false
      errorCalled = false
      success = () -> fail("success handler should not have been called!"); successCalled = true
      failure = (error) -> expect(error).toBe ERROR_MSG; errorCalled = true
      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})
      webQuery = client.buildWebQuery(URL, success, failure)
      webQuery.execute()
      expect(successCalled).toBe false
      expect(errorCalled).toBe true
      expect(@logSnk.getEventCount()).toBe 2
      expect(@logSnk.getEvents()[1]).toContain("ServiceClient::AjaxCall to #{URL} failed")
      expect(@logSnk.getEvents()[1]).toContain(ERROR_MSG)

  describe 'retrieveEnvironments', ->
    it 'handles a successful call to retrieve environments', ->
      querySuccessFired = false
      queryFailureFired = false
      success = () -> querySuccessFired = true
      failure = () -> queryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {results: ENVIRONMENTS})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveEnvironments(success, failure)

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/setting")

    it 'handles an unsuccessful call to retrieve environments', ->
      environmentQuerySuccessFired = false
      environmentQueryFailureFired = false
      success = (args) -> expect(args).toBe ENVIRONMENTS; environmentQuerySuccessFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; environmentQueryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveEnvironments(success, failure)

      expect(environmentQuerySuccessFired).toBe false
      expect(environmentQueryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/setting")

  describe 'retrieveApplications', ->
    it 'handles a successful call to retrieve applications', ->
      querySuccessFired = false
      queryFailureFired = false
      success = (args) -> expect(args).toBe ENVIRONMENTS; querySuccessFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {results: ENVIRONMENTS})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveApplications(ENVIRONMENTS[0], success, failure)

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}")

    it 'handles an unsuccessful call to retrieve applications', ->
      querySuccessFired = false
      queryFailureFired = false
      success = (args) -> expect(args).toBe ENVIRONMENTS; querySuccessFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveApplications(ENVIRONMENTS[0], success, failure)

      expect(querySuccessFired).toBe false
      expect(queryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}")

  describe 'retrieveScopes', ->
    it 'handles a successful call to retrieve scopes', ->
      querySuccessFired = false
      queryFailureFired = false
      success = (args) -> expect(args).toBe SCOPES; querySuccessFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {results: SCOPES})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveScopes(ENVIRONMENTS[0], APPLICATIONS[0], success, failure)

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}")

    it 'handles an unsuccessful call to retrieve scopes', ->
      querySuccessFired = false
      queryFailureFired = false
      success = (args) -> expect(args).toBe SCOPES; querySuccessFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveScopes(ENVIRONMENTS[0], APPLICATIONS[0], success, failure)

      expect(querySuccessFired).toBe false
      expect(queryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}")

  describe 'retrieveSettings', ->
    it 'handles a successful call to retrieve settings', ->
      querySuccessFired = false
      queryFailureFired = false
      success = (args) -> expect(args).toBe SETTINGS; querySuccessFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {results: SETTINGS})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveSettings(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], success, failure)

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}")

    it 'handles an unsuccessful call to retrieve settings', ->
      querySuccessFired = false
      queryFailureFired = false
      success = (args) -> expect(args).toBe SETTINGS; querySuccessFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveSettings(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], success, failure)

      expect(querySuccessFired).toBe false
      expect(queryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}")

  describe 'retrieveConfigurations', ->
    it 'handles a successful call to retrieve configurations', ->
      successFired = false
      failureFired = false
      success = (args) -> expect(args).toBe CONFIGURATIONS; successFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; failureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {results: CONFIGURATIONS})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0], null, success, failure)

      expect(successFired).toBe true
      expect(failureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}/#{SETTINGS[0]}")

    it 'handles an unsuccessful call to retrieve configurations', ->
      successFired = false
      failureFired = false
      success = (args) -> expect(args).toBe CONFIGURATIONS; successFired = true
      failure = (args) -> expect(args).toBe ERROR_MSG; failureFired = true

      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0], null, success, failure)

      expect(successFired).toBe false
      expect(failureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}/#{SETTINGS[0]}")

    it 'uses the cache for settings', ->
      successFired = 0
      failureFired = 0
      success = (args) -> expect(args[0]).toBe CONFIGURATIONS[0]; successFired++
      failure = (args) -> expect(args).toBe ERROR_MSG; failureFired++

      mockAjaxProvider = new MockAjaxProvider(@logger, {results: CONFIGURATIONS})
      client = new CentralConfigurationRepositoryClient(@logger, {lib: mockAjaxProvider})

      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0], null, success, failure)
      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0], null, success, failure)
      Utils.sleep(1003)
      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0], null, success, failure)

      cacheStats = client.cache.getStats()

      expect(successFired).toBe 3
      expect(failureFired).toBe 0
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}/#{SETTINGS[0]}")

      console.log(JSON.stringify(cacheStats))

      expect(cacheStats.cacheAttempts).toBe 3
      expect(cacheStats.cacheHits).toBe 1
      expect(cacheStats.cacheMisses).toBe 1
      expect(cacheStats.cacheExpiries).toBe 1
