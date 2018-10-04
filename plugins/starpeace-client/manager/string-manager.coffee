
STRINGS = {
  'industry.category.none.label': 'None'
  'industry.category.civics.label': 'Civics'
  'industry.category.commerce.label': 'Commerce'
  'industry.category.industries.label': 'Industries'
  'industry.category.logistics.label': 'Logistics'
  'industry.category.offices.label': 'Offices'
  'industry.category.residentials.label': 'Residentials'
  'industry.category.services.label': 'Services'
}

export default class StringManager
  constructor: (@asset_manager, @event_listener, @game_state) ->
    @requested_language_strings = false

    @assets_loaded = true

  has_assets: () -> @has_assets

  queue_asset_load: () ->
    return if @requested_language_strings
    @requested_language_strings = true
    # @asset_manager.queue('news.static.en', './news.static.en.json', (resource) =>
    #   @static_news = _.shuffle(resource.data)
    # )

  string: (key) ->
    # FIXME: TODO: replace with dynamicaclly loaded language assets
    STRINGS[key]
