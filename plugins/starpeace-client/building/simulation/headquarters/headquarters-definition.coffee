import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity.coffee'

export default class HeadquartersDefinition extends SimulationDefinition
  @TYPE: () -> 'HEADQUARTERS'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new HeadquartersDefinition(json)
    definition.labor = _.map(json.labor, ResourceQuantity.from_json)
    definition.satellite = json.satellite || false
    definition.satellite_category = json.satelliteCategory
    definition
