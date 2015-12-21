module.exports =
  parse: (body) ->
    return if typeof body != 'string'
    JSON.parse(body) # TODO: compressing
  compose: (body) ->
    return if typeof body != 'object'
    JSON.stringify(body) # TODO: compressing
