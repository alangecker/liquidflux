i40router = require 'i40'
Logger = require('../Logger')('Router')
Route = require '../classes/Route'

module.exports = Router =

  # Routerscripts
  i40:
    GET: new i40router()
    POST: new i40router()
    DELETE: new i40router()

  _routes:
    GET: []
    POST: []
    DELETE: []

  updateHandler: null
  setUpdateHandler: (@updateHandler) ->
    # also update every route
    for type,routes  of @_routes
      route.sendUpdate = @updateHandler for route in routes

  # add list of routes
  add: (routes) ->
    for route in routes
      if route not instanceof Route
        Logger.error "Route is no instance of 'Route'", route

      @_routes[route.type].push route
      @i40[route.type].addRoute route.route, ->
      route.sendUpdate = @updateHandler




  # route an instance of Request
  route: (request) ->

    # match request
    i40res = @i40[request.type].match(request.path)
    return request.error(code:404) if not i40res

    # find Route instance
    route = null
    for r in @_routes[request.type]
      if r.route == i40res.route
        route = r
        break
    if not route
      Logger.error "route #{type} #{i40res.route} is invalid"
      return false

    request.params = i40res.params
    route.process(request)
