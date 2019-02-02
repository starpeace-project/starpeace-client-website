

export default class BookmarkFolder
  constructor: (@parent_id, @id, @order, options={}) ->
    @children = []

    if options.name_key?.length
      @name_key = options.name_key
    else if options.name?.length
      @name = options.name

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

  @new_town_folder: () ->
    new BookmarkFolder('bookmark-poi', 'bookmark-towns', 0, { type:'TOWN', name_key:'ui.menu.bookmarks.section.towns' })

  @new_mausoleum_folder: () ->
    new BookmarkFolder('bookmark-poi', 'bookmark-mausoleums', 1, { type:'MAUSOLEUM', name_key:'ui.menu.bookmarks.section.mausoleums' })


  @new_corporation_folder: (company_id, company_name, seal_id) ->
    new BookmarkFolder('bookmark-corporation', "bookmark-corp-#{company_id}", -1, { type:'CORPORATION', name:company_name, seal_id:seal_id })

  @new_industry_folder: (root_id, id, industry_type) ->
    new BookmarkFolder(root_id, id, -1, { type:'INDUSTRY', name_key:industry_type.text_key, industry_type:industry_type.type })


  @new_folder: (root_id, id, name, order) ->
    new BookmarkFolder(root_id, id, order, { name:name, draggable:true })
