
export default class MetadataConcrete
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new MetadataConcrete(json.id)
    metadata.atlas_key = json.atlas
    metadata.frames = json.frames
    metadata
