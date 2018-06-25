
class MenuState
  constructor: () ->
    @show_menu_favorites = false
    @main_menu = null


  hide_all_menus: () ->
    @show_menu_favorites = false
    @main_menu = null

  toggle_menu_planetary: () ->
    @main_menu = if @main_menu == 'planetary' then null else 'planetary'
    @show_menu_favorites = false

  toggle_menu_favorites: () ->
    @show_menu_favorites = !@show_menu_favorites

  toggle_menu_tycoon: () ->
    @main_menu = if @main_menu == 'tycoon' then null else 'tycoon'

  toggle_menu_building: () ->
    @main_menu = if @main_menu == 'building' then null else 'building'

  toggle_menu_mail: () ->
    @main_menu = if @main_menu == 'mail' then null else 'mail'

  toggle_menu_chat: () ->
    @main_menu = if @main_menu == 'chat' then null else 'chat'

  toggle_menu_options: () ->
    @main_menu = if @main_menu == 'options' then null else 'options'

  toggle_menu_help: () ->
    @main_menu = if @main_menu == 'help' then null else 'help'


export default MenuState
