
export default class Bookmark
  constructor: (@parent_id, @id, @name, @order, @map_x, @map_y, options={}) ->
    @hidden = false

    @type = options?.type || 'LOCATION'

    @building_id = if options?.building_id?.length then options.building_id else null
    @corporation_id = if options?.corporation_id?.length then options.corporation_id else null

    @draggable = if options.draggable? then options.draggable else false

  is_folder: -> false
