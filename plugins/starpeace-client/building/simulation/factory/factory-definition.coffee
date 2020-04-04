import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import FactoryStage from '~/plugins/starpeace-client/building/simulation/factory/factory-stage.coffee'

export default class FactoryDefinition extends SimulationDefinition
  @TYPE: () -> 'FACTORY'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new FactoryDefinition(json)
    definition.stages = _.map(json.stages, FactoryStage.from_json)
    definition
