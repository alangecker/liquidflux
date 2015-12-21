redis = require 'redis'
Logger = require('../Logger')('RedisClient')
class RedisClient
  client: null
  ready: false
  lastError: null
  constructor: (uri) ->
    @client = redis.createClient(uri)
    @client.on "error", (err) =>
      err = err.toString()
      if err != @lastError
        Logger.error "Error #{err}"
        @lastError = err
    @client.on "ready", =>
      Logger.log "Redis connected"
      @ready = true
    @client.on "end", =>
      Logger.log "Connection lost"
      @ready = false

  onReady: (cb) ->
    @client.on "ready", cb

  subscribe: (channel) ->
    if @ready
      @client.subscribe channel
    else
      @client.on "ready", =>
        @client.subscribe channel

  publish: (channel, message) ->
    @client.publish channel, message


  onMessage: (cb) ->
    if @ready
      @client.on 'message', cb
    else
      @client.on "ready", =>
        @client.on 'message', cb


  # TODO: reconnect!!


module.exports = RedisClient
