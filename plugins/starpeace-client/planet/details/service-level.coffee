
export default class ServiceLevel
  constructor: () ->

  @from_json: (json) ->
    level = new ServiceLevel()
    level.type = json.type
    level.value = json.value
    level
