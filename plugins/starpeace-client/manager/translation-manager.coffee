
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

export default class TranslationManager
  constructor: (@asset_manager, @event_listener, @options, @game_state) ->
    @requested_language_strings = false

    @requested_translations = {}
    @translations_by_language_code = {}

    @assets_loaded = true

  has_assets: () ->
    Object.keys(@translations_by_language_code[@options.language()] || {}).length

  queue_asset_load: () ->
    current_language = @options.language()
    return if @requested_translations[current_language] || @translations_by_language_code[current_language]?
    @requested_translations[current_language] = true
    @asset_manager.queue("translations.#{current_language.toLowerCase()}", "./translations.#{current_language.toLowerCase()}.json", (resource) =>
      @translations_by_language_code[resource.data.language_code] = {}
      @translations_by_language_code[resource.data.language_code][translation.id] = translation for translation in resource.data.translations
    )

  text: (key) ->
    @translations_by_language_code[@options.language()]?[key]?.value
