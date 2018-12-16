
export default class MetadataPlane
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new MetadataPlane(json.id)
    metadata.atlas_key = json.atlas
    metadata.frames = json.frames
    metadata.w = json.w
    metadata.h = json.h
    metadata
