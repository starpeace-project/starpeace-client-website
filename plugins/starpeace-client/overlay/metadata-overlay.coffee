
export default class MetadataOverlay
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new MetadataOverlay(json.id)
    metadata.atlas_key = json.atlas
    metadata.frames = json.frames
    metadata
