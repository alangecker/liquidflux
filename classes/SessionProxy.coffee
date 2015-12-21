Logger = require('../Logger')('Session')

# TODO:
# if session has no active socket:
# - save every packet until socket is reconnecting

class SessionProxy
  socket: null
  id: null #'message',
  constructor: (@socket, @id) ->
    Logger.log "new session #{@id}"
  updateSocket: (@socket) ->
    Logger.log "reopen session #{@id}"

  # send response to specific session
  send: (id, header, body) ->
    return Logger.error "ERROR: socket for session #{@id} doesnt exist anymore" if not @socket
    @socket.emit('response', id, header, body)

  update: (header, body) ->
    return Logger.error "ERROR: socket for session #{@id} doesnt exist anymore" if not @socket
    @socket.emit('update', null, header, body)



module.exports = SessionProxy
