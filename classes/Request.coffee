Logger = require('../Logger')('Request')

class Request
  id: null
  session: null
  type: null
  path: null
  body: null
  sendHandler: null
  cacheable: false
  listen: false

  constructor: (o) ->

    @id = o.id
    @session = o.session
    @type = o.header.type
    @path = o.header.path
    @body = o.body
    @sendHandler = o.send
    Logger.log "new request: #{@type} #{@path}"

    # @setCacheable()
    # @setListen()
    # @success({iDid:'it'})
    # setTimeout (=>
    #   @update({'new':'value'})
    # ), 2000

  setCacheable: -> @cacheable = true
  setListen: -> @listen = true

  getOptions: ->
    options =
      id: @id
      session: @session.id
    options.cacheable = true if @cacheable
    options.listen = true if @listen
    return options

  success: (body) =>
    Logger.log "successful: #{@type} #{@path}"

    header =
      type: @type
      path: @path

    @sendHandler @getOptions(), header, body

  error: (body) ->
    Logger.error "failed: #{@type} #{@path}", body
    header =
      type: @type
      path: @path
      error: true
    @sendHandler @getOptions(), header, body


module.exports = Request
