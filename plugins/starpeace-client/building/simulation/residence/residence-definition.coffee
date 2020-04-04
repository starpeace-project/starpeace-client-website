import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'

export default class ResidenceDefinition extends SimulationDefinition
  @TYPE: () -> 'RESIDENCE'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new ResidenceDefinition(json)
    definition.resident_type = json.residentType
    definition.capacity = json.capacity
    definition.efficiency = json.efficiency
    definition.crime_resistence = json.crimeResistence || 0
    definition.pollution_resistence = json.pollutionResistence || 0
    definition
