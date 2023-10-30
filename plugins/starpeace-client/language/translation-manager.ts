import _ from 'lodash';

import BankDefinition from '~/plugins/starpeace-client/building/simulation/bank/bank-definition.coffee';
import MausoleumDefinition from '~/plugins/starpeace-client/building/simulation/civic/mausoleum-definition.coffee';
import FactoryDefinition from '~/plugins/starpeace-client/building/simulation/factory/factory-definition.coffee';
import HeadquartersDefinition from '~/plugins/starpeace-client/building/simulation/headquarters/headquarters-definition.coffee';
import AntennaDefinition from '~/plugins/starpeace-client/building/simulation/media/antenna-definition.coffee';
import MediaStationDefinition from '~/plugins/starpeace-client/building/simulation/media/media-station-definition.coffee';
import OfficeDefinition from '~/plugins/starpeace-client/building/simulation/office/office-definition.coffee';
import ParkDefinition from '~/plugins/starpeace-client/building/simulation/park/park-definition.coffee';
import ResidenceDefinition from '~/plugins/starpeace-client/building/simulation/residence/residence-definition.coffee';
import ServiceDefinition from '~/plugins/starpeace-client/building/simulation/service/service-definition.coffee';
import StorageDefinition from '~/plugins/starpeace-client/building/simulation/storage/storage-definition.coffee';
import StoreDefinition from '~/plugins/starpeace-client/building/simulation/store/store-definition.coffee';

import Translation from '~/plugins/starpeace-client/language/translation';
import Utils from '~/plugins/starpeace-client/utils/utils.coffee';

import DURATION from '~/plugins/starpeace-client/language/language-duration.json';
import IDENTITY from '~/plugins/starpeace-client/language/language-identity.json';
import MISC from '~/plugins/starpeace-client/language/language-misc.json';
import OVERLAY from '~/plugins/starpeace-client/language/language-overlay.json';

import TOOLBAR_INSPECT from '~/plugins/starpeace-client/language/language-toolbar-inspect.json';
import TOOLBAR_RIBBON from '~/plugins/starpeace-client/language/language-toolbar-ribbon.json';

import UI_MENU_BOOKMARKS from '~/plugins/starpeace-client/language/language-ui-menu-bookmarks.json';
import UI_MENU_CHAT from '~/plugins/starpeace-client/language/language-ui-menu-chat.json';
import UI_MENU_COMPANY from '~/plugins/starpeace-client/language/language-ui-menu-company.json';
import UI_MENU_CONSTUCTION from '~/plugins/starpeace-client/language/language-ui-menu-construction.json';
import UI_MENU_CORPORATION from '~/plugins/starpeace-client/language/language-ui-menu-corporation.json';
import UI_MENU_GALAXY from '~/plugins/starpeace-client/language/language-ui-menu-galaxy.json';
import UI_MENU_HELP from '~/plugins/starpeace-client/language/language-ui-menu-help.json';
import UI_MENU_MAIL from '~/plugins/starpeace-client/language/language-ui-menu-mail.json';
import UI_MENU_OPTIONS from '~/plugins/starpeace-client/language/language-ui-menu-options.json';
import UI_MENU_POLITICS from '~/plugins/starpeace-client/language/language-ui-menu-politics.json';
import UI_MENU_RANKINGS from '~/plugins/starpeace-client/language/language-ui-menu-rankings.json';
import UI_MENU_RELEASE_NOTES from '~/plugins/starpeace-client/language/language-ui-menu-release-notes.json';
import UI_MENU_RESEARCH from '~/plugins/starpeace-client/language/language-ui-menu-research.json';
import UI_MENU_TOWN_SEARCH from '~/plugins/starpeace-client/language/language-ui-menu-town-search.json';
import UI_MENU_TYCOON_DETAILS from '~/plugins/starpeace-client/language/language-ui-menu-tycoon-details.json';
import UI_MENU_TYCOON_SEARCH from '~/plugins/starpeace-client/language/language-ui-menu-tycoon-search.json';

import UI_PAGE_LAYOUT from '~/plugins/starpeace-client/language/language-ui-page-layout.json';

import UI_WORKFLOW_LOADING from '~/plugins/starpeace-client/language/language-ui-workflow-loading.json';
import UI_WORKFLOW_UNIVERSE from '~/plugins/starpeace-client/language/language-ui-workflow-universe.json';

const LANGUAGE_STRINGS = [
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


export default class TranslationManager {
  asset_manager: any;
  ajax_state: any;
  options: any;
  client_state: any;

  translations_by_language_code: Record<string, Record<string, string>> = {};

  constructor (asset_manager: any, ajax_state: any, options: any, client_state: any) {
    this.asset_manager = asset_manager;
    this.ajax_state = ajax_state;
    this.options = options;
    this.client_state = client_state;

    for (const language_values of LANGUAGE_STRINGS) {
      for (const [text_key, languages] of Object.entries(language_values)) {
        for (const [language_code, value] of Object.entries(languages)) {
          if (!this.translations_by_language_code[language_code]) {
            this.translations_by_language_code[language_code] = {};
          }
          this.translations_by_language_code[language_code][text_key] = value
        }
      }
    }
  }

  text (key: Translation | string | undefined): string | undefined {
    if (!key) {
      return undefined;
    }
    else if (key instanceof Translation) {
      return key.forCode(this.options.language()) ?? key.forCode('EN') ?? '';
    }
    else {
      return this.translations_by_language_code[this.options.language()]?.[key] ?? this.translations_by_language_code['EN']?.[key] ?? key;
    }
  }

  resource_details (resourceId: string, maxVelocity: number): any {
    const type = this.client_state.core.planet_library.resource_type_for_id(resourceId);
    const unit = type ? this.client_state.core.planet_library.resource_unit_for_id(type.unit_id) : undefined;
    const amount = maxVelocity * 24;
    return {
      type: type,
      unit: unit,
      amount: amount < 1 ? amount * 7 : amount,
      duration: amount < 1 ? 'duration.week' : 'duration.day'
    }
  }

  label_for_building (building: any): string {
    const simulation_definition = building ? this.client_state.core.building_library.simulation_definition_for_id(building.definition_id) : undefined;
    if (simulation_definition?.type == 'TOWNHALL') {
      const town = building.townId ? this.client_state.planet.town_for_id(building.townId) : undefined;
      if (town) {
        return `${this.text('misc.selected.building.townhall')}\n${town.name}\n${town.population} ${this.text('misc.selected.building.townhall.population')}`;
      }
    }
    else if (simulation_definition?.type == 'PORTAL') {
      const town = building.townId ? this.client_state.planet.town_for_id(building.townId) : undefined;
      if (town) {
        return `${this.text('misc.selected.building.portal')}\n${town.name}`;
      }
    }
    else if (simulation_definition?.type == 'TRADECENTER') {
      const town = building.townId ? this.client_state.planet.town_for_id(building.townId) : undefined;
      const seal = town?.seal_id ? this.client_state.core.planet_library.seal_for_id(town.seal_id) : undefined;
      if (seal) {
        return `${this.text('misc.selected.building.tradecenter')}\n${seal.name_short}`;
      }
    }
    else {
      const building_name = building?.name;
      const company = building ? this.client_state.core.company_cache.metadata_for_id(building.company_id) : undefined;
      const company_name = company?.name
      const building_profit = 0; // TODO: FIXME: hookup

      if (building_name && company_name) {
        return `${building_name}\n${company_name}\n($${building_profit}/h)`;
      }
    }
    return this.text('misc.selected.building.scanning') ?? '';
  }


  description_for_building (building_definition: any): string {
    const text_separator = this.text('misc.and');

    const simulation_definition = this.client_state.core.building_library.simulation_definition_for_id(building_definition.id);

    if (simulation_definition instanceof BankDefinition) {
      return this.text('ui.menu.construction.description.bank.label') ?? '';
    }
    else if (simulation_definition instanceof MausoleumDefinition) {
      return this.text('ui.menu.construction.description.mausoleum.label') ?? '';
    }
    else if (simulation_definition instanceof FactoryDefinition) {
      const template_description = _.template(this.text('ui.menu.construction.description.industry.label'))
      const template_output = _.template(this.text('ui.menu.construction.description.industry.output.label'))
      const template_input = _.template(this.text('ui.menu.construction.description.industry.input.label'))

      const description_parts = []
      for (const stage of simulation_definition.stages) {
        const output_label_parts = _.map(stage.outputs, (output) => {
          const resurce = this.resource_details(output.resource_id, output.max_velocity);
          return template_output({amount: resurce.amount, resource: this.text(resurce.type?.label_plural), unit: this.text(resurce.unit?.label_plural), duration: this.text(resurce.duration)});
        });

        if (output_label_parts.length) {
          description_parts.push(template_description({output: Utils.join_with_oxford_comma(output_label_parts, text_separator)}));
        }

        const inputs = _.map(stage.inputs, (input) => this.text(this.client_state.core.planet_library.resource_type_for_id(input.resource_id)?.label_plural));
        if (inputs.length) {
          description_parts.push(template_input({input: Utils.join_with_oxford_comma(inputs, text_separator)}));
        }
      }

      return description_parts.join(' ');
    }
    else if (simulation_definition instanceof HeadquartersDefinition) {
      return this.text('ui.menu.construction.description.headquarters.label') ?? '';
    }
    else if (simulation_definition instanceof AntennaDefinition) {
      const template_antenna = _.template(this.text('ui.menu.construction.description.media.antenna.label'));
      return template_antenna({ range: (simulation_definition.range * 20) });
    }
    else if (simulation_definition instanceof MediaStationDefinition) {
      return this.text('ui.menu.construction.description.media.station.label') ?? '';
    }
    else if (simulation_definition instanceof OfficeDefinition) {
      const template_efficiency = _.template(this.text('ui.menu.construction.description.real_estate.efficiency.label'));
      const template_offices = _.template(this.text('ui.menu.construction.description.offices.rent.label'));

      const params_efficiency = { efficiency: Math.round(simulation_definition.efficiency * 100) };
      const params_offices = { amount: simulation_definition.capacity };

      return `${template_offices(params_offices)}. ${template_efficiency(params_efficiency)}`;
    }
    else if (simulation_definition instanceof ParkDefinition) {
      // TODO: no existing descriptions to re-use
      return '';
    }
    else if (simulation_definition instanceof ResidenceDefinition) {
      const residential_type = this.client_state.core.planet_library.type_for_id(building_definition.industry_type_id);
      const template_efficiency = _.template(this.text('ui.menu.construction.description.real_estate.efficiency.label'))
      const template_inhabitants = _.template(this.text('ui.menu.construction.description.residential.inhabitants.label'))
      const template_resistences = _.template(this.text('ui.menu.construction.description.residential.resistences.label'))

      const params_efficiency = { efficiency: Math.round(simulation_definition.efficiency * 100) }
      const params_inhabitants = { amount: simulation_definition.capacity }
      const params_resistences = { crime: Math.round(simulation_definition.crime_resistence * 100), pollution: Math.round(simulation_definition.pollution_resistence * 100) }

      return `${this.text(residential_type.label)}. ${template_inhabitants(params_inhabitants)}. ${template_resistences(params_resistences)}. ${template_efficiency(params_efficiency)}`;
    }
    else if (simulation_definition instanceof ServiceDefinition) {
      // TODO: no existing descriptions to re-use
      return '';
    }
    else if (simulation_definition instanceof StorageDefinition) {
      const template_description = _.template(this.text('ui.menu.construction.description.warehouse.label'));
      const template_output = _.template(this.text('ui.menu.construction.description.warehouse.output.label'));

      const storage_parts = _.map(simulation_definition.storage, (storage) => {
        const type = this.client_state.core.planet_library.resource_type_for_id(storage.resource_id);
        const unit = type ? this.client_state.core.planet_library.resource_unit_for_id(type.unit_id) : undefined;
        return template_output({amount: storage.max, resource: this.text(type?.label_plural), unit: this.text(unit?.label_plural)})
      });

      return template_description({storage: Utils.join_with_oxford_comma(storage_parts, text_separator)})
    }
    else if (simulation_definition instanceof StoreDefinition) {
      const template_sells = _.template(this.text('ui.menu.construction.description.store.sells.label'));
      const template_provides = _.template(this.text('ui.menu.construction.description.store.provides.label'));
      const template_resource = _.template(this.text('ui.menu.construction.description.store.resource.label'));

      const sell_parts = [];
      const buy_parts = [];
      const provide_parts = [];

      for (const product of simulation_definition.products) {
        const inputs = product.inputs.map((i) => _.pick(i, 'resource_id', 'max_velocity'));
        const outputs = product.outputs.map((o) => _.pick(o, 'resource_id', 'max_velocity'));

        if (_.isEqual(inputs, outputs)) {
          for (const output of outputs) {
            const resource = this.resource_details(output.resource_id, output.max_velocity);
            sell_parts.push(template_resource({amount: resource.amount, resource: this.text(resource.type?.label_plural), unit: this.text(resource.unit?.label_plural), duration: this.text(resource.duration)}));
          }
        }
        else {
          for (const input of inputs) {
            const resource = this.resource_details(input.resource_id, input.max_velocity);
            buy_parts.push(template_resource({amount: resource.amount, resource: this.text(resource.type?.label_plural), unit: this.text(resource.unit?.label_plural), duration: this.text(resource.duration)}));
          }
          for (const output of outputs) {
            const resource = this.resource_details(output.resource_id, output.max_velocity);
            provide_parts.push(template_resource({amount: resource.amount, resource: this.text(resource.type?.label_plural), unit: this.text(resource.unit?.label_plural), duration: this.text(resource.duration)}));
          }
        }
      }

      const descriptions = [];
      if (sell_parts.length) {
        descriptions.push(template_sells({sells: Utils.join_with_oxford_comma(sell_parts, text_separator)}));
      }
      if (buy_parts.length && provide_parts.length) {
        descriptions.push(template_provides({buys: Utils.join_with_oxford_comma(buy_parts, text_separator), provides: Utils.join_with_oxford_comma(provide_parts, text_separator)}));
      }
      return descriptions.join(' ');
    }

    return '';
  }
}
