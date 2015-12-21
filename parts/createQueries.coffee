assign = require 'object-assign'
EventEmitter = require('events').EventEmitter

Logger = require('../Logger')('createQueries')
Dispatcher  = require './Dispatcher'


runningManager = document.runningManager =
  queries: {}
  isRunning: (pod,name,args) ->
    key = "#{pod}::#{name}"
    return false if not @queries[key]
    for instance in @queries[key]
      return true if @compareArgs(instance,args)
    return false

  compareArgs: (a,b) ->
    return false if a.length != b.length
    aString = JSON.stringify(a)
    bString = JSON.stringify(b)
    return aString.localeCompare(bString) == 0


  runs: (pod,name, args) ->
    key = "#{pod}::#{name}"
    if @queries[key]
      @queries[key].push args
    else
      @queries[key] = [args]

  stopped: (pod,name,args) ->
    key = "#{pod}::#{name}"
    if not @queries[key] || @queries[key].length <= 1
      delete @queries[key]
    else
      for instance,i in @queries[key]
        if @compareArgs(instance,args)
          @queries[key].splice(i,1)
          return




_callQuery = (query,name,pod) ->
  return (args...) ->
    return if runningManager.isRunning(pod,name,args)
    Logger.log "call #{pod}::#{name}(#{args.join(', ')})"

    runningManager.runs(pod,name,args)
    query.do.bind(
      update: (response...) ->
        Logger.log "got update #{pod}::#{name}(#{args.join(', ')})", response
        query.onUpdate.bind(dispatch: Dispatcher.dispatch)(response...) if query.onUpdate
        runningManager.stopped(pod,name,args)
      success: (response...) ->
        Logger.log "response #{pod}::#{name}(#{args.join(', ')})", response
        query.onSuccess.bind(dispatch: Dispatcher.dispatch)(response...) if query.onSuccess
        runningManager.stopped(pod,name,args)
      error: (response...) ->
        Logger.error  "error while #{pod}::#{name}(#{args.join(', ')})", response
        runningManager.stopped(pod,name,args)
        query.onError.bind(dispatch: Dispatcher.dispatch)(response...) if query.onError
      dispatch: Dispatcher.dispatch
    )(args...)




module.exports = (obj) ->
    response = {}
    for key,query of obj
      if key == 'pod'
        response.pod = obj.pod
      else if query.do == undefined
        Logger.error "#{obj.pod}::#{key} needs an do() method"
      else
        response[key] = _callQuery(query, key, obj.pod)
    return response
