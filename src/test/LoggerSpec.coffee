"use strict"

describe 'Logger', ->
  @logger = null
  @logSink = null
  TEST_MESSAGE = "TEST MESSAGE"

  beforeEach(() ->
    @logSink = new TestLoggingSink()
    @logger = new Logger({ level: LogLevel.ALL, sink: @logSink})
  )

  it 'Logs at the debug level', ->
    @logger.debug(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 1
    expect(@logSink.getEvents()[0]).toContain('DEBUG')

  it 'Logs at the error level', ->
    @logger.error(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 1
    expect(@logSink.getEvents()[0]).toContain('ERROR')

  it 'Logs at the info level', ->
    @logger.info(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 1
    expect(@logSink.getEvents()[0]).toContain('INFO')

  it 'Logs at the warn level', ->
    @logger.warn(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 1
    expect(@logSink.getEvents()[0]).toContain('WARN')

  it 'Does not log when LogLevel is NONE', ->
    logger = new Logger({level: LogLevel.NONE, sink: @logSink})
    logger.debug(TEST_MESSAGE)
    logger.error(TEST_MESSAGE)
    logger.info(TEST_MESSAGE)
    logger.warn(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 0

  it 'Logs only error events when LogLevel is ERROR', ->
    logger = new Logger({level: LogLevel.ERROR, sink: @logSink})
    logger.debug(TEST_MESSAGE)
    logger.error(TEST_MESSAGE)
    logger.info(TEST_MESSAGE)
    logger.warn(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 1

  it 'Logs only error and warn events when LogLevel is WARN', ->
    logger = new Logger({level: LogLevel.WARN, sink: @logSink})
    logger.debug(TEST_MESSAGE)
    logger.error(TEST_MESSAGE)
    logger.info(TEST_MESSAGE)
    logger.warn(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 2

  it 'Logs error, warn, and info events when LogLevel is INFO', ->
    logger = new Logger({level: LogLevel.INFO, sink: @logSink})
    logger.debug(TEST_MESSAGE)
    logger.error(TEST_MESSAGE)
    logger.info(TEST_MESSAGE)
    logger.warn(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 3

  it 'Logs error, warn, debug and info events when LogLevel is DEBUG', ->
    logger = new Logger({level: LogLevel.DEBUG, sink: @logSink})
    logger.debug(TEST_MESSAGE)
    logger.error(TEST_MESSAGE)
    logger.info(TEST_MESSAGE)
    logger.warn(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 4

  it 'Allows changing the Log Level', ->
    logger = new Logger({level: LogLevel.ALL, sink: @logSink})
    logger.debug(TEST_MESSAGE)
    logger.error(TEST_MESSAGE)
    logger.info(TEST_MESSAGE)
    logger.warn(TEST_MESSAGE)
    logger.setLogLevel(LogLevel.INFO)
    logger.debug(TEST_MESSAGE)
    expect(@logSink.getEventCount()).toBe 4
