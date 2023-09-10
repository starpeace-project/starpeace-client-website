import _ from 'lodash'

import BankDefinition from '~/plugins/starpeace-client/building/simulation/bank/bank-definition.coffee'
import MausoleumDefinition from '~/plugins/starpeace-client/building/simulation/civic/mausoleum-definition.coffee'
import FactoryDefinition from '~/plugins/starpeace-client/building/simulation/factory/factory-definition.coffee'
import HeadquartersDefinition from '~/plugins/starpeace-client/building/simulation/headquarters/headquarters-definition.coffee'
import AntennaDefinition from '~/plugins/starpeace-client/building/simulation/media/antenna-definition.coffee'
import MediaStationDefinition from '~/plugins/starpeace-client/building/simulation/media/media-station-definition.coffee'
import OfficeDefinition from '~/plugins/starpeace-client/building/simulation/office/office-definition.coffee'
import ParkDefinition from '~/plugins/starpeace-client/building/simulation/park/park-definition.coffee'
import ResidenceDefinition from '~/plugins/starpeace-client/building/simulation/residence/residence-definition.coffee'
import ServiceDefinition from '~/plugins/starpeace-client/building/simulation/service/service-definition.coffee'
import StorageDefinition from '~/plugins/starpeace-client/building/simulation/storage/storage-definition.coffee'
import StoreDefinition from '~/plugins/starpeace-client/building/simulation/store/store-definition.coffee'


import Translation from '~/plugins/starpeace-client/language/translation'
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
          @translations_by_language_code[language_code] = {} unless @translations_by_language_code[language_code]?
          @translations_by_language_code[language_code][text_key] = value

  text: (key) ->
    if key instanceof Translation
      key[@options.language()] || key['EN']
    else
      value = @translations_by_language_code[@options.language()]?[key]
      value = @translations_by_language_code['EN']?[key] unless value? || @options.language() == 'EN'
      value || key

  resource_details: (resource_id, max_velocity) ->
    type = @client_state.core.planet_library.resource_type_for_id(resource_id)
    unit = if type? then @client_state.core.planet_library.resource_unit_for_id(type.unit_id) else null
    amount = max_velocity * 24
    {
      type: type
      unit: unit
      amount: if amount < 1 then amount * 7 else amount
      duration: if amount < 1 then 'duration.week' else 'duration.day'
    }

  description_for_building: (building_definition) ->
    text_separator = @text('misc.and')

    simulation_definition = @client_state.core.building_library.simulation_definition_for_id(building_definition.id)

    if simulation_definition instanceof BankDefinition
      return @text('ui.menu.construction.description.bank.label')

    if simulation_definition instanceof MausoleumDefinition
      return @text('ui.menu.construction.description.mausoleum.label')

    if simulation_definition instanceof FactoryDefinition
      template_description = _.template(@text('ui.menu.construction.description.industry.label'))
      template_output = _.template(@text('ui.menu.construction.description.industry.output.label'))
      template_input = _.template(@text('ui.menu.construction.description.industry.input.label'))

      description_parts = []
      for stage in simulation_definition.stages
        output_label_parts = _.map(stage.outputs, (output) =>
          resurce = @resource_details(output.resource_id, output.max_velocity)
          template_output({amount: resurce.amount, resource: @text(resurce.type?.label_plural), unit: @text(resurce.unit?.label_plural), duration: @text(resurce.duration)})
        )
        description_parts.push template_description({output: Utils.join_with_oxford_comma(output_label_parts, text_separator)}) if output_label_parts.length

        inputs = _.map(stage.inputs, (input) => @text(@client_state.core.planet_library.resource_type_for_id(input.resource_id)?.label_plural))
        description_parts.push template_input({input: Utils.join_with_oxford_comma(inputs, text_separator)}) if inputs.length

      return description_parts.join(' ')

    if simulation_definition instanceof HeadquartersDefinition
      return @text('ui.menu.construction.description.headquarters.label')

    if simulation_definition instanceof AntennaDefinition
      template_antenna = _.template(@text('ui.menu.construction.description.media.antenna.label'))
      return template_antenna({ range: (simulation_definition.range * 20) })

    if simulation_definition instanceof MediaStationDefinition
      return @text('ui.menu.construction.description.media.station.label')

    if simulation_definition instanceof OfficeDefinition
      residential_type = @client_state.core.planet_library.type_for_id(building_definition.industry_type_id)
      template_efficiency = _.template(@text('ui.menu.construction.description.real_estate.efficiency.label'))
      template_offices = _.template(@text('ui.menu.construction.description.offices.rent.label'))

      params_efficiency = { efficiency: Math.round(simulation_definition.efficiency * 100) }
      params_offices = { amount: simulation_definition.capacity }

      return "#{template_offices(params_offices)}. #{template_efficiency(params_efficiency)}"

    if simulation_definition instanceof ParkDefinition
      # TODO: no existing descriptions to re-use
      return ''

    if simulation_definition instanceof ResidenceDefinition
      residential_type = @client_state.core.planet_library.type_for_id(building_definition.industry_type_id)
      template_efficiency = _.template(@text('ui.menu.construction.description.real_estate.efficiency.label'))
      template_inhabitants = _.template(@text('ui.menu.construction.description.residential.inhabitants.label'))
      template_resistences = _.template(@text('ui.menu.construction.description.residential.resistences.label'))

      params_efficiency = { efficiency: Math.round(simulation_definition.efficiency * 100) }
      params_inhabitants = { amount: simulation_definition.capacity }
      params_resistences = { crime: Math.round(simulation_definition.crime_resistence * 100), pollution: Math.round(simulation_definition.pollution_resistence * 100) }

      return "#{@text(residential_type.label)}. #{template_inhabitants(params_inhabitants)}. #{template_resistences(params_resistences)}. #{template_efficiency(params_efficiency)}"

    if simulation_definition instanceof ServiceDefinition
      # TODO: no existing descriptions to re-use
      return ''

    if simulation_definition instanceof StorageDefinition
      template_description = _.template(@text('ui.menu.construction.description.warehouse.label'))
      template_output = _.template(@text('ui.menu.construction.description.warehouse.output.label'))

      storage_parts = _.map(simulation_definition.storage, (storage) =>
        type = @client_state.core.planet_library.resource_type_for_id(storage.resource_id)
        unit = if type? then @client_state.core.planet_library.resource_unit_for_id(type.unit_id) else null
        template_output({amount: storage.max, resource: @text(type?.label_plural), unit: @text(unit?.label_plural)})
      )

      return template_description({storage: Utils.join_with_oxford_comma(storage_parts, text_separator)})

    if simulation_definition instanceof StoreDefinition
      template_sells = _.template(@text('ui.menu.construction.description.store.sells.label'))
      template_provides = _.template(@text('ui.menu.construction.description.store.provides.label'))
      template_resource = _.template(@text('ui.menu.construction.description.store.resource.label'))

      sell_parts = []
      buy_parts = []
      provide_parts = []

      for product in simulation_definition.products
        inputs = product.inputs.map((i) => _.pick(i, 'resource_id', 'max_velocity'))
        outputs = product.outputs.map((o) => _.pick(o, 'resource_id', 'max_velocity'))

        if _.isEqual(inputs, outputs)
          for output in outputs
            resurce = @resource_details(output.resource_id, output.max_velocity)
            sell_parts.push(template_resource({amount: resurce.amount, resource: @text(resurce.type?.label_plural), unit: @text(resurce.unit?.label_plural), duration: @text(resurce.duration)}))
        else
          for input in inputs
            resurce = @resource_details(input.resource_id, input.max_velocity)
            buy_parts.push(template_resource({amount: resurce.amount, resource: @text(resurce.type?.label_plural), unit: @text(resurce.unit?.label_plural), duration: @text(resurce.duration)}))
          for output in outputs
            resurce = @resource_details(output.resource_id, output.max_velocity)
            provide_parts.push(template_resource({amount: resurce.amount, resource: @text(resurce.type?.label_plural), unit: @text(resurce.unit?.label_plural), duration: @text(resurce.duration)}))

      descriptions = []
      descriptions.push(template_sells({sells: Utils.join_with_oxford_comma(sell_parts, text_separator)})) if sell_parts.length
      descriptions.push(template_provides({buys: Utils.join_with_oxford_comma(buy_parts, text_separator), provides: Utils.join_with_oxford_comma(provide_parts, text_separator)})) if buy_parts.length && provide_parts.length
      return descriptions.join(' ')

    ''
