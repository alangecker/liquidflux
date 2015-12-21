moment = require 'moment'
module.exports = (prefix) ->
  time: ->
    '['+moment().format('HH:mm:ss')+']'
  log: (args...) ->
    args[0] = @time()+"[#{prefix}] #{args[0]}"
    console.log args...
  error: (args...) ->
    args[0] = @time()+"[#{prefix}] #{args[0]}"
    console.error args...
