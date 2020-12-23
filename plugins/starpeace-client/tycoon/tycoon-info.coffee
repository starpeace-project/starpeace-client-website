
export default class TycoonInfo
  constructor: () ->

  @fromJson: (json) ->
    metadata = new TycoonInfo()
    metadata.type = json.type
    metadata.tycoonId = json.tycoonId
    metadata.tycoonName = json.tycoonName
    metadata.corporationId = json.corporationId
    metadata.corporationName = json.corporationName
    metadata
