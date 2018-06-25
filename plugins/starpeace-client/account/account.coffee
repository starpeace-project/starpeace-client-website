
class Account
  constructor: (@id, @access_token) ->

    @registered = true

  is_valid: () ->
    (@is_visitor() || @username?.length) && @access_token?.length

  is_visitor: () ->
    @id == 'visitor'

  to_string: () -> @toString()
  toString: () -> "#{@id}:#{@access_token}"


  companies: () ->
    []


  @for_identity: (identity) ->
    new Promise (resolve, reject) ->
      # FIXME: TODO: replace with API call
      throw "only visitors are supported" unless identity.is_visitor()

      resolve(new Account('visitor', 'token'))

export default Account
