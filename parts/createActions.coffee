Logger = require('../Logger')('createActions')
Dispatcher = require './Dispatcher'
module.exports = (obj) ->
  response = {}
  for key,value of obj
    if typeof value != 'function'
      Logger.error "#{key} is no method"
    else
      response[key] = value.bind(
        dispatch:Dispatcher.dispatch
      )
  return response
