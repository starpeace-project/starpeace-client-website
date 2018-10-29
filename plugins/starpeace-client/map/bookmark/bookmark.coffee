
export default class Bookmark
  constructor: (@parent_id, @id, @name, @order, @map_x, @map_y, options={}) ->
    @hidden = false

    @type = options?.type || 'LOCATION'
    @draggable = if options.draggable? then options.draggable else false

  is_folder: -> false
