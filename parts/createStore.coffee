assign = require 'object-assign'
EventEmitter = require('events').EventEmitter

Logger = require('../Logger')('createStore')
LoggerStore = require('../Logger')('Store')
Dispatcher  = require './Dispatcher'




module.exports = (obj) ->
  Store = assign {
    getInitialState: -> {}
  }, EventEmitter.prototype, obj

  Store.bindAction = (action, callback) ->
    if action == undefined
      Logger.error "action is undefined, maybe forgot to set constant?"
    else
      if typeof callback == 'function'
        Dispatcher.register(action, callback.bind(Store))
      else
        Logger.error "callback for #{action} is no function"

  Store.fetch = (options) ->
    value = options.locally.bind(Store)()
    if value == undefined && options.loaded != true
      options.remotely.bind(Store)()
      options.loaded = true
      return options.default
    else
      return value


  Store.emitChange = (args...) ->
    args[0] = 'CHANGE' if not args[0]
    LoggerStore.log "#{Store.pod} -> #{args[0]}"
    Store.emit args...

  keyWords = ['get', 'update', 'set', 'do', 'is']
  for keyWord in keyWords
    if Store[keyWord]
      for key,func of Store[keyWord]
        Store[keyWord+key[0].toUpperCase()+key.substr(1)] = func.bind(Store)


  Store.initialise()
  Store.state = Store.getInitialState()
  return Store
