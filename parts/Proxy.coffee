http = require('http').createServer()
socketio = require('socket.io')

RedisClient = require '../classes/RedisClient'
Session = require '../classes/SessionProxy'
Cache = require '../classes/Cache'
Logger = require('../Logger')('Proxy')

module.exports =
  redisRequest: null
  redisResponse: null
  redisUpdate: null
  sessions: {}
  cache: null
  caching: false
  packets: []

  listener:
    'GET':{}
    'POST':{}
    'DELETE':{}


  listen: (port, redis) ->
    @cache = new Cache
    @connectToBackend(redis)
    @openSocketIO(port)


  # connect to redis server
  connectToBackend: (redis) ->
    @redisRequest = new RedisClient redis

    @redisResponse = new RedisClient redis
    @redisResponse.subscribe 'response'
    @redisResponse.onMessage (channel, response) =>
      @handleResponse(JSON.parse(response))

    @redisUpdate = new RedisClient redis
    @redisUpdate.subscribe 'update'
    @redisUpdate.onMessage (channel, response) =>
        @handleUpdate(JSON.parse(response))



  # listen to socket.io connections
  openSocketIO: (port) ->
    io = socketio(http)
    http.listen port, =>
      Logger.log "proxy runs on port #{port}"
      io.on 'connection',(socket) =>
        @newSocket(socket)



  # if new socket.io connection is established:
  # listen to events
  newSocket: (socket) ->
    socket.on 'session', (sessionId) =>
      socket.sessionId = sessionId
      if @sessions[sessionId]
        @sessions[sessionId].updateSocket(socket)
      else
        @sessions[sessionId] = new Session(socket, sessionId)
      socket.on 'request', @handleRequest(@sessions[sessionId])
    socket.on 'disconnect', =>
      # TODO: set clear timeout
      # clear every listener


  # handle an new request from the client
  # check is cached? if not: publish request to redis server
  handleRequest: (session) -> return (id, header, body) =>
      Logger.log "Request from #{session.id}: #{header.type} #{header.path}"

      # caching activated?
      if @caching
        cached = @cache.get([header.type, header.path])
        if cached
          session.send(id, cached.header, cached.body)
          Logger.log "Response to #{session.id} (cached): #{cached.header.type} #{cached.header.path}"
          return

      # connecton to redis server?
      if not @redisRequest.ready
        session.send(id, {
          type: header.type
          path: header.path
          error: true
        }, {code:504})
        return

      # publish new request
      else
        @packets.push id
        @redisRequest.publish 'request', JSON.stringify
          id: id
          sid: session.id
          header: header
          body: body



  handleResponse: (m) ->
    # response for one of our clients?
    return if not @sessions[m.session] or @packets.indexOf(m.id) == -1

    # remove from open packet list
    @packets.splice(@packets.indexOf(m.id), 1)


    # is response cacheable and caching active?
    # then save it!
    if m.cacheable and @caching
      Logger.log "update cache (#{m.header.type} #{m.header.path})"
      @cache.set([m.header.type,m.header.path], {
        header: m.header
        body: m.body
      })
    # should i listen to updates for this request?
    if m.listen
      if not @listener[m.header.type][m.header.path]
        @listener[m.header.type][m.header.path] = [m.session]
      else
        @listener[m.header.type][m.header.path].push m.session if @listener[m.header.type][m.header.path].indexOf(m.session) == -1


    Logger.log "Response to #{m.session}: #{m.header.type} #{m.header.path}", {cacheable:m.cacheable, listen:m.listen}
    @sessions[m.session].send(m.id, m.header, m.body)


  handleUpdate: (m) ->
    # is response cacheable and caching active?
    # then save it!
    if m.cacheable && @caching
      Logger.log "update cache (#{m.header.type} #{m.header.path})"
      @cache.set([m.header.type,m.header.path], {
        header: m.header
        body: m.body
      })
    return if not @listener[m.header.type][m.header.path]

    # send update to every listening session
    for sessionId in @listener[m.header.type][m.header.path]
      Logger.log "Update to #{sessionId}: #{m.header.type} #{m.header.path}"
      @sessions[sessionId].update(m.header, m.body)
