
import AssetLibrary from '~/plugins/starpeace-client/state/core/library/asset-library.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class TranslationsLibrary extends AssetLibrary
  constructor: () ->
    super()

    @has_loaded_by_language_code = {}
    @translations_by_language_code = {}

  has_metadata: (language_code) -> @has_loaded_by_language_code[language_code] == true

  load_translations_partial: (language_code, translations) ->
    @translations_by_language_code[language_code] ||= {}
    @translations_by_language_code[language_code][translation.id] = translation.value for translation in translations

  load_translations: (language_code, translations) ->
    @load_translations_partial(language_code, translations)
    @has_loaded_by_language_code[language_code] = true
    @notify_listeners()
