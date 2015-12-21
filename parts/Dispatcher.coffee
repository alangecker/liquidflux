Logger = require('../Logger')('Dispatcher')
module.exports = Dispatcher =
  callbacks: {}
  register: (action, callback) ->
    if action == undefined
      Logger.error "undefined action, maybe forgot to define constant?"
    Logger.log "register #{action}"
    if Dispatcher.callbacks[action]
      Dispatcher.callbacks[action].push callback
    else
      Dispatcher.callbacks[action] = [callback]


  dispatch: (action, payload) ->
    if action == undefined
      Logger.error "undefined action, maybe forgot to define constant?"
    Logger.log "dispatch #{action}", payload
    # no callbacks?
    if not Dispatcher.callbacks[action]
      # return an fulfilled promise
      return new Promise (fulfill) -> fulfill()

    # get all promises an push into array
    promises = []
    promises.push cb(payload) for cb in Dispatcher.callbacks[action]

    # return them combined
    return Promise.all(promises)
