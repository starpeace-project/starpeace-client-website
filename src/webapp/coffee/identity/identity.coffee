

window.starpeace ||= {}
window.starpeace.identity ||= {}
window.starpeace.identity.Identity = class Identity

  constructor: (@id) ->
    @id = 'visitor' unless @id?.length

    @authentication_token = null

  authenticate: () ->
    # FIXME: TODO: do social identity auth, get token, save something to localStorage

  is_authenticated: () ->
    @is_visitor() || @authentication_token?.length

  is_visitor: () ->
    @id == 'visitor'

  reset_and_destroy : () ->
    # FIXME: TODO: clear localStorage, reset all cognito state
    @authentication_token = null

  to_string: () -> @toString()
  toString: () -> "#{@id}:#{if @authentication_token?.length then @authentication_token else 'anonymous'}"

  @visitor: () ->
    new Identity('visitor')

  @from_local_storage: () ->
    # FIXME: TODO: integrate with localStorage and cognito
    null

