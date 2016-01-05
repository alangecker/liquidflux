Logger = require('../Logger')('Route')

class Route
  type: null
  route: null
  listener: []
  middleware: []
  action: null
  content: null
  cacheable: false
  updatePaths: {}
  sendUpdate: null

  constructor: (options) ->
    @type = options.type
    @route = options.route
    @middleware = options.middleware if options.middleware
    @listener = options.listener if options.listener
    @cacheable = options.cacheable if options.cacheable
    @action = options.action
    @content = options.content
    @updatePaths = {}

    @addListener()
    Logger.log "Route #{@type} #{@route} created"


  addListener: ->
    return if not @listener.length
    return Logger.error("Error @ Route #{@type} #{@route}: cant set listener without an content-parsing function") if not @content
    for listener,index in @listener
      listener[0].addListener( listener[1], @updateHandler(index).bind(@))

  updateHandler: (index) ->
    return () ->
      condition = @listener[index][2]
      for path,params of @updatePaths
        @content params, (body) =>
          @sendUpdate({cacheable:@cacheable}, {type:@type, path:path}, body)
      # TODO: condition


  process: (request) ->
    request.setCacheable() if @cacheable
    if @listener.length
      request.setListen()
      @updatePaths[request.path] = request.params

    @processMiddleware(request)

  processMiddleware: (request) ->
    i = 0
    error = (code, msg, payload) =>
      request.error(code:code, message:msg, payload:payload)
    next = =>
      if i < @middleware.length
        cb = @middleware[i++]
        if typeof cb != 'function'
          Logger.error "Error: #{@type} #{@path} - middleware[#{i-1}] ist not an callback"
        else
          cb(request, next, error)
      else
        @processAction(request)
    next()

  processAction: (request) ->
    if @action
      action = @action(request)
      if action instanceof Promise
        action.then (payload) =>
          if @content
            @processContent(request, payload)
          else
            request.success()
        , (err) ->
          request.error(err)

      else if @content
        @processContent(request)
    else if @content
      @processContent(request)

  processContent: (request, dispatcherResponse) ->
    @content request.params, request.success.bind(request), dispatcherResponse

module.exports = Route
