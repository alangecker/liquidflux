module.exports = (prefix, keys) ->
  response = {}
  response[k] = prefix+'.'+k for k in keys
  return response
