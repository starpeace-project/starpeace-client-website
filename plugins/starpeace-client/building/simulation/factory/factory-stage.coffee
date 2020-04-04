import _ from 'lodash'

import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity.coffee'

export default class FactoryStage

  @from_json: (json) ->
    stage = new FactoryStage()
    stage.index = json.index
    stage.duration = json.duration
    stage.stage_inputs = json.stageInputs
    stage.labor = _.map(json.labor, ResourceQuantity.from_json)
    stage.operations = _.map(json.operations, ResourceQuantity.from_json)
    stage.inputs = _.map(json.inputs, ResourceQuantity.from_json)
    stage.outputs = _.map(json.outputs, ResourceQuantity.from_json)
    stage
