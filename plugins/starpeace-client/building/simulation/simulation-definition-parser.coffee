import _ from 'lodash'

import BankDefinition from '~/plugins/starpeace-client/building/simulation/bank/bank-definition.coffee'
import CapitolDefinition from '~/plugins/starpeace-client/building/simulation/civic/capitol-definition.coffee'
import MausoleumDefinition from '~/plugins/starpeace-client/building/simulation/civic/mausoleum-definition.coffee'
import PortalDefinition from '~/plugins/starpeace-client/building/simulation/civic/portal-definition.coffee'
import TownhallDefinition from '~/plugins/starpeace-client/building/simulation/civic/townhall-definition.coffee'
import TradecenterDefinition from '~/plugins/starpeace-client/building/simulation/civic/tradecenter-definition.coffee'
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


DEFINITIONS = [
  BankDefinition,
  CapitolDefinition,
  MausoleumDefinition,
  PortalDefinition,
  TownhallDefinition,
  TradecenterDefinition,
  FactoryDefinition,
  HeadquartersDefinition,
  AntennaDefinition,
  MediaStationDefinition,
  OfficeDefinition,
  ParkDefinition,
  ResidenceDefinition,
  ServiceDefinition,
  StorageDefinition,
  StoreDefinition
]
DEFINITIONS_BY_TYPE = _.keyBy(DEFINITIONS, (def) -> def.TYPE())

export default class SimulationDefinitionParser

  @from_json: (json) ->
    return DEFINITIONS_BY_TYPE[json.type].from_json(json) if DEFINITIONS_BY_TYPE[json.type]?
    throw "unknown simulation type #{json.type}"
