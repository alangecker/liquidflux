module.exports =
  registeredListener: []
  componentDidMount: ->
    @registeredListener = []
    return unless @setStoreListener

    for listener in @setStoreListener()
      listener[1] = @refreshFluxStates unless listener[1]
      listener[2] = 'CHANGE' unless listener[2]

      if listener[3] # condition
        cb = (args...) =>
          listener[1]() if listener[3].bind(this)(args...)
      else
        cb = listener[1]

      @registeredListener.push
        store: listener[0]
        key: listener[2]
        cb: cb
      listener[0].addListener listener[2], cb

  componentWillUnmount: ->
    return unless @setStoreListener
    for listener in @registeredListener
      listener.store.removeListener listener.key, listener.cb


  componentWillReceiveProps: (nextProps) ->
    @refreshFluxStates(null, nextProps)

  getInitialState: ->
    if @getFluxState
      return @getFluxState(@props)
    else if @getFluxStates
      return @__deprecatedFluxStates(@props)
    else
      return {}

  refreshFluxStates: (p, props) ->
    props = if props then props else @props
    @setState @getFluxState(props) if @getFluxState
    @setState @__deprecatedFluxStates(props) if @getFluxStates

  __deprecatedFluxStates: (props) ->
    return @getFluxStates(props)
