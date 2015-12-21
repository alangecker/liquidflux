class Cache
  _cache: {}
  set: (key, value) -> @_cache[@arrayToKey(key)] = value
  get: (key) -> @_cache[@arrayToKey(key)]

  arrayToKey: (a) ->
    return a if typeof a != 'object'
    return a.join('__')

module.exports = Cache
