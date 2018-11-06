
export default class Identity
  constructor: (@type, @authentication_token) ->
    @id = 'visitor' unless @id?.length

  authenticate: () ->
    # FIXME: TODO: do social identity auth, get token, save something to localStorage

  is_authenticated: () ->
    @is_visitor() || @authentication_token?.length

  is_visitor: () -> @type == 'visitor'
  is_tycoon: () -> @type == 'tycoon'

  reset_and_destroy : () ->
    # FIXME: TODO: clear localStorage, reset all cognito state
    @authentication_token = null

  to_string: () -> @toString()
  toString: () -> "#{@type}:#{if @authentication_token?.length then @authentication_token else 'anonymous'}"

  @visitor: () ->
    new Identity('visitor', 'anonymous')

  @mock_tycoon: () ->
    new Promise (done) =>
      # FIXME: TODO: integrate with localStorage and cognito
      setTimeout(=>
        done(new Identity('tycoon', 'auth-token-1'))
      , 1000)
