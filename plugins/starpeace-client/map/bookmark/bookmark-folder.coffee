

export default class BookmarkFolder
  constructor: (@id, @name, options={}) ->
    @children = []

    @type = if options.type?.length then options.type else 'GENERIC'
    @seal = if options.seal?.length then options.seal else null

    @level = 0
    @expanded = false
    @hidden = false

  is_folder: -> true

  add_child: (folder_or_location) ->
    folder_or_location.level = @level + 1
    @children.push(folder_or_location)

  toggle: ->
    return unless @children.length

    @expanded = !@expanded
