

export default class BookmarkFolder
  constructor: (@parent_id, @id, @name, @order, options={}) ->
    @children = []

    @type = if options.type?.length then options.type else 'GENERIC'
    @seal_id = if options.seal_id?.length then options.seal_id else null
    @industry_type = if options.industry_type?.length then options.industry_type else null
    @draggable = if options.draggable? then options.draggable else false

    @expanded = false
    @hidden = false

  is_folder: -> true

  add_child: (folder_or_location) ->
    folder_or_location.level = @level + 1
    @children.push(folder_or_location)

  toggle: ->
    return unless @children.length

    @expanded = !@expanded
