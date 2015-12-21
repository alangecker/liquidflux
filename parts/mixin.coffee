module.exports =
  componentDidMount: ->
    return unless @setStoreListener
    for listener in @setStoreListener()
      listener[1] = @refreshFluxStates unless listener[1]
      listener[2] = 'CHANGE' unless listener[2]
      listener[0].addListener listener[2], listener[1]

  componentWillUnmount: ->
    return unless @setStoreListener
    for listener in @setStoreListener()
      listener[1] = @refreshFluxStates unless listener[1]
      listener[2] = 'CHANGE' unless listener[2]
      listener[0].removeListener listener[2], listener[1]


  componentWillReceiveProps: (nextProps) ->
    @refreshFluxStates(null, nextProps)

  getInitialState: ->
    return @getFluxStates(@props) if @getFluxStates

  refreshFluxStates: (p, props) ->
    props = if props then props else @props
    @setState @getFluxStates(props) if @getFluxStates
