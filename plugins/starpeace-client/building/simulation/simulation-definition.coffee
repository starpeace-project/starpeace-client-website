import _ from 'lodash'

import ConstructionQuantity from '~/plugins/starpeace-client/building/simulation/construction-quantity.coffee'

export default class SimulationDefinition
  constructor: (json) ->
    @id = json.id
    @type = json.type
    @max_level = json.maxLevel
    @construction_inputs = _.map(json.constructionInputs, ConstructionQuantity.from_json)
    @prestige = json.prestige || 0
    @maintainance = json.maintainance || 0
    @beauty = json.beauty || 0
    @pollution = json.pollution || 0
