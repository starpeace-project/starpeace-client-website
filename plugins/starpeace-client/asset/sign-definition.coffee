
export default class SignDefinition
  constructor: () ->

  @from_json: (json) ->
    metadata = new SignDefinition()
    metadata.id = json.id
    metadata.atlas_key = json.atlas
    metadata.frames = json.frames
    metadata.s_x = json.s_x
    metadata.s_y = json.s_y
    metadata
