
import _ from 'lodash'
import Vue from 'vue'

import FactoryDefinition from '~/plugins/starpeace-client/building/simulation/factory/factory-definition.coffee'
import StorageDefinition from '~/plugins/starpeace-client/building/simulation/storage/storage-definition.coffee'

import Translation from '~/plugins/starpeace-client/language/translation.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import DURATION from '~/plugins/starpeace-client/language/language-duration.json'
import IDENTITY from '~/plugins/starpeace-client/language/language-identity.json'
import MISC from '~/plugins/starpeace-client/language/language-misc.json'
import OVERLAY from '~/plugins/starpeace-client/language/language-overlay.json'

import TOOLBAR_INSPECT from '~/plugins/starpeace-client/language/language-toolbar-inspect.json'
import TOOLBAR_RIBBON from '~/plugins/starpeace-client/language/language-toolbar-ribbon.json'

import UI_MENU_BOOKMARKS from '~/plugins/starpeace-client/language/language-ui-menu-bookmarks.json'
import UI_MENU_CHAT from '~/plugins/starpeace-client/language/language-ui-menu-chat.json'
import UI_MENU_COMPANY from '~/plugins/starpeace-client/language/language-ui-menu-company.json'
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
import UI_WORKFLOW_UNIVERSE from '~/plugins/starpeace-client/language/language-ui-workflow-universe.json'

LANGUAGE_STRINGS = [
  DURATION,
  IDENTITY,
  MISC,
  OVERLAY,
  TOOLBAR_INSPECT,
  TOOLBAR_RIBBON,
  UI_MENU_BOOKMARKS,
  UI_MENU_CHAT,
  UI_MENU_COMPANY,
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
  UI_WORKFLOW_UNIVERSE
]


export default class TranslationManager
  constructor: (@asset_manager, @ajax_state, @options, @client_state) ->

    @translations_by_language_code = {}

    for language_values in LANGUAGE_STRINGS
      for text_key,languages of language_values
        for language_code,value of languages
          Vue.set(@translations_by_language_code, language_code, {}) unless @translations_by_language_code[language_code]?
          Vue.set(@translations_by_language_code[language_code], text_key, value)

  text: (key) ->
    if key instanceof Translation
      key[@options.language()] || key['EN']
    else
      value = @translations_by_language_code[@options.language()]?[key]
      value = @translations_by_language_code['EN']?[key] unless value? || @options.language() == 'EN'
      value || key


  description_for_building: (building_definition) ->
    text_separator = @text('misc.and')

    simulation_definition = @client_state.core.building_library.simulation_definition_for_id(building_definition.id)
    if simulation_definition instanceof FactoryDefinition
      template_description = _.template(@text('ui.menu.construction.description.industry.label'))
      template_output = _.template(@text('ui.menu.construction.description.industry.output.label'))
      template_input = _.template(@text('ui.menu.construction.description.industry.input.label'))

      description_parts = []
      for stage in simulation_definition.stages
        output_label_parts = _.map(stage.outputs, (output) =>
          type = @client_state.core.planet_library.resource_type_for_id(output.resource_id)
          unit = if type? then @client_state.core.planet_library.resource_unit_for_id(type.unit_id) else null
          template_output({amount: output.max_velocity, resource: @text(type?.label_plural), unit: @text(unit?.label_plural), duration: @text('duration.day')})
        )
        description_parts.push template_description({output: Utils.join_with_oxford_comma(output_label_parts, text_separator)}) if output_label_parts.length

        inputs = _.map(stage.inputs, (input) => @text(@client_state.core.planet_library.resource_type_for_id(input.resource_id)?.label_plural))
        description_parts.push template_input({input: Utils.join_with_oxford_comma(inputs, text_separator)}) if inputs.length

      return description_parts.join(' ')

    if simulation_definition instanceof StorageDefinition
      template_description = _.template(@text('ui.menu.construction.description.warehouse.label'))
      template_output = _.template(@text('ui.menu.construction.description.warehouse.output.label'))

      storage_parts = _.map(simulation_definition.storage, (storage) =>
        type = @client_state.core.planet_library.resource_type_for_id(storage.resource_id)
        unit = if type? then @client_state.core.planet_library.resource_unit_for_id(type.unit_id) else null
        template_output({amount: storage.max, resource: @text(type?.label_plural), unit: @text(unit?.label_plural)})
      )

      return template_description({storage: Utils.join_with_oxford_comma(storage_parts, text_separator)})

    ''
