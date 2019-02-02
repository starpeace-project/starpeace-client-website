<template lang='pug'>
#options-container
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.menu.options.header')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('options')")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      form.columns
        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label.group-header {{translate('ui.menu.options.header.general')}}
            .column.is-paddingless.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-option(:label="translate('ui.menu.options.option.general.header.label')", :value="options.option('general.show_header')", v-on:toggle="options.toggle('general.show_header')")
          menu-option(:label="translate('ui.menu.options.option.general.fps.label')", :value="options.option('general.show_fps')", v-on:toggle="options.toggle('general.show_fps')")
          menu-option(:label="translate('ui.menu.options.option.general.mini_map.label')", :value="options.option('general.show_mini_map')", v-on:toggle="options.toggle('general.show_mini_map')")
          menu-option(:label="translate('ui.menu.options.option.general.music.label')", :value="options.option('music.show_game_music')", v-on:toggle="options.toggle('music.show_game_music')")
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label {{translate('ui.menu.options.option.general.language.label')}}:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  language-select(:language_code='language_code', v-on:changed='change_language')

        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label.group-header {{translate('ui.menu.options.header.graphics')}}
            .column.is-paddingless.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-option(:label="translate('ui.menu.options.option.graphics.trees.label')",  :value="options.option('renderer.trees')", v-on:toggle="options.toggle('renderer.trees')")
          menu-option(:label="translate('ui.menu.options.option.graphics.buildings.label')", :value="options.option('renderer.buildings')", v-on:toggle="options.toggle('renderer.buildings')")
          menu-option(:label="translate('ui.menu.options.option.graphics.building_animations.label')", :value="options.option('renderer.building_animations')", v-on:toggle="options.toggle('renderer.building_animations')")
          menu-option(:label="translate('ui.menu.options.option.graphics.building_effects.label')", :value="options.option('renderer.building_effects')", v-on:toggle="options.toggle('renderer.building_effects')")
          menu-option(:label="translate('ui.menu.options.option.graphics.planes.label')", :value="options.option('renderer.planes')", v-on:toggle="options.toggle('renderer.planes')")

        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label.group-header {{translate('ui.menu.options.header.locations')}}
            .column.is-paddingless.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-option(:label="translate('ui.menu.options.option.locations.poi.label')", :value="options.option('bookmarks.points_of_interest')", v-on:toggle="options.toggle('bookmarks.points_of_interest')")
          menu-option(:label="translate('ui.menu.options.option.locations.poi_capital.label')", :value="options.option('bookmarks.capital')", v-on:toggle="options.toggle('bookmarks.capital')")
          menu-option(:label="translate('ui.menu.options.option.locations.poi_towns.label')", :value="options.option('bookmarks.towns')", v-on:toggle="options.toggle('bookmarks.towns')")
          menu-option(:label="translate('ui.menu.options.option.locations.poi_mausoleums.label')", :value="options.option('bookmarks.mausoleums')", v-on:toggle="options.toggle('bookmarks.mausoleums')")
          menu-option(:label="translate('ui.menu.options.option.locations.corporation.label')", :value="options.option('bookmarks.corporation')", v-on:toggle="options.toggle('bookmarks.corporation')")

    footer.card-footer
      .card-footer-item.reset-item
        a.button.is-primary.is-medium.is-outlined(v-on:click.stop.prevent='reset_options', :disabled='!can_reset') {{translate('ui.menu.options.actions.reset')}}
      .card-footer-item.save-item
        a.button.is-primary.is-medium(v-on:click.stop.prevent='save_options', :disabled='!is_dirty') {{translate('ui.menu.options.actions.save')}}

</template>

<script lang='coffee'>
import LanguageSelect from '~/components/misc/language-select.vue'
import MenuOption from '~/components/menu/options/menu-option.vue'

export default
  components:
    'language-select': LanguageSelect
    'menu-option': MenuOption

  props:
    managers: Object
    client_state: Object

  mounted: ->
    @client_state?.options?.subscribe_options_listener =>
      @can_reset = @options?.can_reset()
      @is_dirty = @options?.is_dirty()
      @language_code = @options?.language()
      @$forceUpdate()

  data: ->
    language_code: if @options? then @options?.language() else 'EN'

    can_reset: @options?.can_reset()
    is_dirty: @options?.is_dirty()

  computed:
    options: -> @client_state?.options

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    change_language: (code) -> @client_state?.options?.set_language(code)
    reset_options: () -> @options.reset_state()
    save_options: () -> @options.save_state()
</script>

<style lang='sass' scoped>

#options-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 4
  justify-content: center
  z-index: 1100

.card
  max-width: 60rem
  width: 100%

  legend
    color: #fff
    font-weight: 1000

  .label
    &.group-header
      border-bottom: 1px solid
      font-weight: 1000
      padding-bottom: .25rem

  .second-group-header
    .field-label
      margin: 0

  .label-column
    color: #fff
    font-weight: 1000

  .toggle-icons
    font-size: 1.5rem
    line-height: 1.5rem
    cursor: pointer
    text-align: center

    .fa-toggle-on
      color: #fff
      font-weight: 1000

  .card-footer
    .card-footer-item
      a
        width: 100%

</style>
