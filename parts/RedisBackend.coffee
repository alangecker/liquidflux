Logger = require('../Logger')('Backend')
Request = require '../classes/Request'
bodyHelpers = require '../helpers/body'
RedisClient = require '../classes/RedisClient'
Router = require './Router'

class Session
  id: null
  constructor: (@id) ->


module.exports =
  redisRequest: null
  redisResponse: null
  sessions: []

  connect: (uri) ->
    @redisRequest = new RedisClient uri
    @redisRequest.subscribe 'request'
    @redisRequest.onMessage (channel, message) =>
      @processRequest(JSON.parse(message))
    @redisResponse = new RedisClient uri
    Router.setUpdateHandler @sendUpdate.bind(@)
    Logger.log "Backend is running"

  processRequest: (request) ->
    @sessions[request.sid] = new Session(request.sid) if not @sessions[request.sid]
    request.session = @sessions[request.sid]
    request.send = @sendResponse.bind(@)
    request.update = @sendUpdate.bind(@)
    request.body = bodyHelpers.parse(request.body)
    Router.route(new Request(request))


  sendResponse: (options, header, body) ->
    console.log 'test'
    res = options
    res.header = header
    res.body = bodyHelpers.compose(body)
    @redisResponse.publish 'response', JSON.stringify res

  sendUpdate: (options, header, body) ->

    res = options
    res.header = header
    res.body = bodyHelpers.compose(body)
    @redisResponse.publish 'update', JSON.stringify res
