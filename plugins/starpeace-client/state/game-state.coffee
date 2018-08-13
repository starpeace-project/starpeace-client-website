
import moment from 'moment'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Identity from '~/plugins/starpeace-client/identity/identity.coffee'
import Account from '~/plugins/starpeace-client/account/account.coffee'

MONTH_SEASONS = {
  0: 'winter'
  1: 'winter'
  2: 'spring'
  3: 'spring'
  4: 'spring'
  5: 'summer'
  6: 'summer'
  7: 'summer'
  8: 'fall'
  9: 'fall'
  10: 'fall'
  11: 'winter'
}

class GameState
  constructor: () ->
    @initialized = false
    @loading = false
    @has_assets = false

    @ajax_requests = 0

    @current_identity_authentication = Identity.from_local_storage()
      .then (identity) =>
        @current_identity = identity
        @current_identity_authentication = null
        Logger.debug "initialized identity <#{@current_identity}> from localStorage"
      .catch (error) ->
        # FIXME: TODO: figure out error handling
    @current_identity = null
    @current_account_authorization = null
    @current_account = null

    @current_planetary_system = null
    @current_planet = null
    # FIXME: TODO: consider loading state from url parameters (planet_id)

    @game_music_playing = false
    @game_music_volume = true

    @view_offset_x = 3600
    @view_offset_y = 4250

    @game_scale = 0.75

    @current_date = '2235-01-01'
    @current_season = 'winter'

    setInterval(=>
      return unless @initialized
      # FIXME: TODO: remove and get from server
      date = moment(@current_date).add(1, 'day')
      @current_date = date.format('YYYY-MM-DD')
      @current_season = MONTH_SEASONS[date.month()]
    , 250)

  start_ajax: () -> @ajax_requests += 1
  finish_ajax: () -> @ajax_requests -= 1

  proceed_as_visitor: () ->
    @current_identity.reset_and_destroy() if @current_identity?
    @current_identity = Identity.visitor()
    Logger.debug "proceeding with visitor identity <#{@current_identity}>"

    @current_account_authorization = Account.for_identity(@current_identity)
      .then (account) =>
        @current_account = account
        @current_account_authorization = null
        Logger.debug "successfully retrieved account <#{@current_account}> for identity"

      .catch (error) ->
        # FIXME: TODO: figure out error handling

  set_planet: (planet) ->
    @current_planet = planet
    Logger.debug "proceeding with planet <#{@current_planet}>"

export default GameState
