module.exports = (prefix, keys) ->
  response = {
    'ROUTE':'ROUTE'
  }
  response[k] = prefix+'.'+k for k in keys
  return response
