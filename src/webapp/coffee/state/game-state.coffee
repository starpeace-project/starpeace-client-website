
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

window.starpeace ||= {}
window.starpeace.state ||= {}
window.starpeace.state.GameState = class GameState

  constructor: () ->
    @initialized = false
    @loading = false

    @view_offset_x = 3600
    @view_offset_y = 4250

    @game_scale = 1

    @current_date = '2235-01-01'
    @current_season = 'winter'

    setInterval(=>
      return unless @initialized
      # FIXME: TODO: remove and get from server
      date = moment(@current_date).add(1, 'day')
      @current_date = date.format('YYYY-MM-DD')
      @current_season = MONTH_SEASONS[date.month()]
    , 250)
