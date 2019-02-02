
import _ from 'lodash'

import DURATION from '~/plugins/starpeace-client/language/language-duration.json'
import IDENTITY from '~/plugins/starpeace-client/language/language-identity.json'
import INDUSTRY_CATEGORY from '~/plugins/starpeace-client/language/language-industry-category.json'
import INDUSTRY_TYPE from '~/plugins/starpeace-client/language/language-industry-type.json'
import LEVEL from '~/plugins/starpeace-client/language/language-level.json'
import MISC from '~/plugins/starpeace-client/language/language-misc.json'
import OVERLAY from '~/plugins/starpeace-client/language/language-overlay.json'
import RESOURCE_TYPE from '~/plugins/starpeace-client/language/language-resource-type.json'
import RESOURCE_UNIT from '~/plugins/starpeace-client/language/language-resource-unit.json'

import TOOLBAR_RIBBON from '~/plugins/starpeace-client/language/language-toolbar-ribbon.json'

import UI_MENU_BOOKMARKS from '~/plugins/starpeace-client/language/language-ui-menu-bookmarks.json'
import UI_MENU_CHAT from '~/plugins/starpeace-client/language/language-ui-menu-chat.json'
import UI_MENU_CONSTUCTION from '~/plugins/starpeace-client/language/language-ui-menu-construction.json'
import UI_MENU_CORPORATION from '~/plugins/starpeace-client/language/language-ui-menu-corporation.json'
import UI_MENU_GALAXY from '~/plugins/starpeace-client/language/language-ui-menu-galaxy.json'
import UI_MENU_HELP from '~/plugins/starpeace-client/language/language-ui-menu-help.json'
import UI_MENU_MAIL from '~/plugins/starpeace-client/language/language-ui-menu-mail.json'
import UI_MENU_OPTIONS from '~/plugins/starpeace-client/language/language-ui-menu-options.json'
import UI_MENU_POLITICS from '~/plugins/starpeace-client/language/language-ui-menu-politics.json'
import UI_MENU_RANKINGS from '~/plugins/starpeace-client/language/language-ui-menu-rankings.json'
import UI_MENU_RELEASE_NOTES from '~/plugins/starpeace-client/language/language-ui-menu-release-notes.json'
import UI_MENU_RESEARCH from '~/plugins/starpeace-client/language/language-ui-menu-research.json'
import UI_MENU_TOWN_SEARCH from '~/plugins/starpeace-client/language/language-ui-menu-town-search.json'
import UI_MENU_TYCOON_DETAILS from '~/plugins/starpeace-client/language/language-ui-menu-tycoon-details.json'
import UI_MENU_TYCOON_SEARCH from '~/plugins/starpeace-client/language/language-ui-menu-tycoon-search.json'

import UI_PAGE_LAYOUT from '~/plugins/starpeace-client/language/language-ui-page-layout.json'

import UI_WORKFLOW_LOADING from '~/plugins/starpeace-client/language/language-ui-workflow-loading.json'
import UI_WORKFLOW_PLANET from '~/plugins/starpeace-client/language/language-ui-workflow-planet.json'
import UI_WORKFLOW_UNIVERSE from '~/plugins/starpeace-client/language/language-ui-workflow-universe.json'

LANGUAGE_STRINGS = [
  DURATION,
  IDENTITY,
  INDUSTRY_CATEGORY,
  INDUSTRY_TYPE,
  LEVEL,
  MISC,
  OVERLAY,
  RESOURCE_TYPE,
  RESOURCE_UNIT,
  TOOLBAR_RIBBON,
  UI_MENU_BOOKMARKS,
  UI_MENU_CHAT,
  UI_MENU_CONSTUCTION,
  UI_MENU_CORPORATION,
  UI_MENU_GALAXY,
  UI_MENU_HELP,
  UI_MENU_MAIL,
  UI_MENU_OPTIONS,
  UI_MENU_POLITICS,
  UI_MENU_RANKINGS,
  UI_MENU_RELEASE_NOTES,
  UI_MENU_RESEARCH,
  UI_MENU_TOWN_SEARCH,
  UI_MENU_TYCOON_DETAILS,
  UI_MENU_TYCOON_SEARCH,
  UI_PAGE_LAYOUT,
  UI_WORKFLOW_LOADING,
  UI_WORKFLOW_PLANET,
  UI_WORKFLOW_UNIVERSE
]


export default class TranslationManager
  constructor: (@asset_manager, @ajax_state, @translations_library, @options) ->
    for language_values in LANGUAGE_STRINGS
      for text_key,languages of language_values
        for language_code,value of languages
          @translations_library.load_translations_partial(language_code, [{ id:text_key, value:value }])

  queue_asset_load: (completion_callback=null) ->
    current_language = @options.language()
    return if @translations_library.has_metadata(current_language) || @ajax_state.is_locked('assets.translations', current_language)

    @ajax_state.lock('assets.translations', current_language)
    @asset_manager.queue("translations.#{current_language.toLowerCase()}", "./translations.#{current_language.toLowerCase()}.json", (resource) =>
      @translations_library.load_translations(current_language, resource.data.translations)
      @ajax_state.unlock('assets.translations', current_language)
      completion_callback() if completion_callback? && _.isFunction(completion_callback)
    )

  text: (key) ->
    value = @translations_library.translations_by_language_code[@options.language()]?[key]
    value = @translations_library.translations_by_language_code['EN']?[key] unless value? || @options.language() == 'EN'
    value || key
