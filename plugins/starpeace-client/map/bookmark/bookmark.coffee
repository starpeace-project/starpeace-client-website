
export default class Bookmark
  constructor: (@id, @name, @map_x, @map_y, options={}) ->
    @hidden = false

    @type = options?.type || 'LOCATION'

  is_folder: -> false
