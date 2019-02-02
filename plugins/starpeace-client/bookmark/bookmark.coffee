
export default class Bookmark
  constructor: (@parent_id, @id, @name, @order, @map_x, @map_y, options={}) ->
    @hidden = false

    @type = options?.type || 'LOCATION'

    @building_id = if options?.building_id?.length then options.building_id else null

    @draggable = if options.draggable? then options.draggable else false

  is_folder: -> false


  @new_town: (order, town_id, town_name, map_x, map_y, building_id) ->
    new Bookmark('bookmark-towns', "bookmark-town-#{town_id}", town_name, order, 1000 - map_y, 1000 - map_x, { type:'TOWN', corporation_id:'IFEL', building_id:building_id })

  @new_corporate_building: (root_id, building_id, building_name, map_x, map_y) ->
    new Bookmark(root_id, "bookmark-building-#{building_id}", building_name, -1, map_x, map_y, { type:'BUILDING', building_id:building_id })


  @new_bookmark: (root_id, id, name, order, map_x, map_y) ->
    new Bookmark(root_id, id, name, order, map_x, map_y, { draggable:true })

  @new_bookmark_building: (root_id, id, building_id, name, order, map_x, map_y) ->
    new Bookmark(root_id, id, name, order, map_x, map_y, { building_id:building_id, draggable:true })
