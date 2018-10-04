
class MenuState
  constructor: () ->
    @show_menu_release_notes = false
    @show_menu_bookmarks = false
    @main_menu = null

  is_any_menu_open: () ->
    @show_menu_bookmarks || @main_menu?.length || @show_menu_release_notes

  hide_all_menus: () ->
    @show_menu_bookmarks = false
    @main_menu = null
    @show_menu_release_notes = false

  toggle_menu_planetary: () ->
    @show_menu_release_notes = false
    @main_menu = if @main_menu == 'planetary' then null else 'planetary'
    @show_menu_bookmarks = false

  toggle_menu_bookmarks: () ->
    @show_menu_release_notes = false if @show_menu_release_notes
    @show_menu_bookmarks = !@show_menu_bookmarks

  toggle_menu_tycoon: () ->
    @show_menu_release_notes = false
    @main_menu = if @main_menu == 'tycoon' then null else 'tycoon'
  toggle_menu_building: () ->
    @show_menu_release_notes = false
    @main_menu = if @main_menu == 'building' then null else 'building'
  toggle_menu_mail: () ->
    @show_menu_release_notes = false
    @main_menu = if @main_menu == 'mail' then null else 'mail'
  toggle_menu_chat: () ->
    @show_menu_release_notes = false
    @main_menu = if @main_menu == 'chat' then null else 'chat'
  toggle_menu_options: () ->
    @show_menu_release_notes = false
    @main_menu = if @main_menu == 'options' then null else 'options'
  toggle_menu_help: () ->
    @show_menu_release_notes = false
    @main_menu = if @main_menu == 'help' then null else 'help'

  toggle_menu_release_notes: () ->
    @main_menu = null if @main_menu?.length
    @show_menu_bookmarks = false if @show_menu_bookmarks
    @show_menu_release_notes = !@show_menu_release_notes

export default MenuState
