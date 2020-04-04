import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import StorageQuantity from '~/plugins/starpeace-client/building/simulation/storage/storage-quantity.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity.coffee'

export default class StorageDefinition extends SimulationDefinition
  @TYPE: () -> 'STORAGE'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new StorageDefinition(json)
    definition.labor = _.map(json.labor, ResourceQuantity.from_json)
    definition.operations = _.map(json.operations, ResourceQuantity.from_json)
    definition.storage = _.map(json.storage, StorageQuantity.from_json)
    definition
