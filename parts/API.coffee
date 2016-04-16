Logger = require('../Logger')('API')
bodyHelpers = require '../helpers/body'

generateRandomString = (strong=false) ->
  if strong
    res = ''
    buf = new Uint8Array(16)
    window.crypto.getRandomValues buf
    res += number.toString(16) for number in buf
    return res
  else
    res = ''
    res += Math.round(Math.random()*15).toString(16) for i in [0...16]
    return res

class API
  sessionId: null
  socket: null
  _updateHandlers: {}
  _packets: {}

  constructor: (url) ->
    @socket = io(url)
    @socket.on 'connect', =>
      @sessionId = generateRandomString(true) unless @sessionId
      Logger.log "sessionId: #{@sessionId}"

      @socket.emit 'session', @sessionId
      @socket.on 'response', @handleResponse.bind(@)
      @socket.on 'update', @handleUpdate.bind(@)

  handleResponse: (id, header, body) ->
    packet = @_packets[id]
    if packet
      if header.error
        packet.reject bodyHelpers.parse(body)
      else
        packet.fulfill bodyHelpers.parse(body)

  handleUpdate: (id, header, body) ->
    handler = @_updateHandlers[header.type+'__'+header.path]
    return unless handler
    cb(bodyHelpers.parse(body)) for cb in handler



  get: (path, onUpdate) ->
    @send('GET', path, null, onUpdate)

  post: (path, body, onUpdate) ->
    @send('POST', path, body, onUpdate)

  delete: (path, body, onUpdate) ->
    @send('DELETE', path, body, onUpdate)

  update: (path, body, onUpdate) ->
    @send('UPDATE', path, body, onUpdate)

  send: (type, path, body, onUpdate) -> new Promise (fulfill, reject) =>
    Logger.log "#{type} #{path}"
    id = generateRandomString()
    if onUpdate
      @_updateHandlers[type+'__'+path] = [] if not @_updateHandlers[type+'__'+path]
      @_updateHandlers[type+'__'+path].push onUpdate
    @_packets[id] =
      fulfill: fulfill
      reject: reject

    if body
      @socket.emit 'request', id, {type:type,path:path}, bodyHelpers.compose(body)
    else
      @socket.emit 'request', id, {type:type,path:path}



module.exports = API
