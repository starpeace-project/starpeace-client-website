<template lang='pug'>
#options-container(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{$translate('ui.menu.options.header')}}
      .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('options')")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      form.columns
        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label.group-header {{$translate('ui.menu.options.header.general')}}
            .column.is-paddingless.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.header.label')", :value="options.option('general.show_header')", @toggle="options.toggle('general.show_header')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.fps.label')", :value="options.option('general.show_fps')", @toggle="options.toggle('general.show_fps')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.mini_map.label')", :value="options.option('general.show_mini_map')", @toggle="options.toggle('general.show_mini_map')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.music.label')", :value="options.option('music.show_game_music')", @toggle="options.toggle('music.show_game_music')")
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label {{$translate('ui.menu.options.option.general.language.label')}}:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  misc-language-select(:language_code='language_code', @changed='change_language')

        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label.group-header {{$translate('ui.menu.options.header.graphics')}}
            .column.is-paddingless.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-options-menu-option(:label="$translate('ui.menu.options.option.graphics.trees.label')",  :value="options.option('renderer.trees')", @toggle="options.toggle('renderer.trees')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.graphics.buildings.label')", :value="options.option('renderer.buildings')", @toggle="options.toggle('renderer.buildings')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.graphics.building_animations.label')", :value="options.option('renderer.building_animations')", @toggle="options.toggle('renderer.building_animations')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.graphics.building_effects.label')", :value="options.option('renderer.building_effects')", @toggle="options.toggle('renderer.building_effects')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.graphics.planes.label')", :value="options.option('renderer.planes')", @toggle="options.toggle('renderer.planes')")

        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                label.label.group-header {{$translate('ui.menu.options.header.locations')}}
            .column.is-paddingless.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi.label')", :value="options.option('bookmarks.points_of_interest')", @toggle="options.toggle('bookmarks.points_of_interest')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi_capital.label')", :value="options.option('bookmarks.capital')", @toggle="options.toggle('bookmarks.capital')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi_mausoleums.label')", :value="options.option('bookmarks.mausoleums')", @toggle="options.toggle('bookmarks.mausoleums')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi_towns.label')", :value="options.option('bookmarks.towns')", @toggle="options.toggle('bookmarks.towns')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.corporation.label')", :value="options.option('bookmarks.corporation')", @toggle="options.toggle('bookmarks.corporation')")

    footer.card-footer
      .card-footer-item.reset-item
        button.button.is-primary.is-medium.is-outlined(@click.stop.prevent='reset_options', :disabled='!can_reset') {{$translate('ui.menu.options.actions.reset')}}
      .card-footer-item.save-item
        button.button.is-primary.is-medium(@click.stop.prevent='save_options', :disabled='!is_dirty') {{$translate('ui.menu.options.actions.save')}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      language_code: this.client_state?.options?.language() ?? 'EN',

      can_reset: this.client_state?.options?.can_reset(),
      is_dirty: this.client_state?.options?.is_dirty()
    };
  },

  computed: {
    options () { return this.client_state.options; }
  },

  mounted () {
    this.client_state.options?.subscribe_options_listener(() => {
      this.can_reset = this.client_state.options?.can_reset() ?? false;
      this.is_dirty = this.client_state.options?.is_dirty() ?? false;
      this.language_code = this.client_state.options?.language() ?? 'EN';
      this.$forceUpdate();
    });
  },

  methods: {
    change_language (code: string) {
      this.client_state.options?.set_language(code);
    },
    reset_options () {
      this.client_state.options?.reset_state();
    },
    save_options () {
      this.client_state.options?.save_state();
    }
  }
}
</script>

<style lang='sass' scoped>

#options-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: start-render
  grid-row-end: end-render
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
