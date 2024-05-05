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
            .column.p-0.is-9
              .field-label
                label.label.group-header {{$translate('ui.menu.options.header.general')}}
            .column.p-0.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.header.label')", :value="options.option('general.show_header')", @toggle="options.toggle('general.show_header')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.fps.label')", :value="options.option('general.show_fps')", @toggle="options.toggle('general.show_fps')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.mini_map.label')", :value="options.option('general.show_mini_map')", @toggle="options.toggle('general.show_mini_map')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.general.music.label')", :value="options.option('music.show_game_music')", @toggle="options.toggle('music.show_game_music')")
          .field.is-horizontal
            .column.p-0.is-9
              .field-label
                label.label {{$translate('ui.menu.options.option.general.language.label')}}:
            .column.p-0.field-body
              .field.is-narrow
                .control
                  misc-language-select(:language_code='language_code', @changed='change_language')

        .column
          .field.is-horizontal
            .column.p-0.is-9
              .field-label
                label.label.group-header {{$translate('ui.menu.options.header.graphics')}}
            .column.p-0.second-group-header
              .field-label
                label.label.group-header &nbsp;
          template(v-for='choice in optionsGraphics')
            menu-options-menu-option(:label='$translate(choice.label)' :hint='$translate(choice.hint)' :value='options.option(choice.type)' @toggle='options.toggle(choice.type)')

        .column
          .field.is-horizontal
            .column.p-0.is-9
              .field-label
                label.label.group-header {{$translate('ui.menu.options.header.locations')}}
            .column.p-0.second-group-header
              .field-label
                label.label.group-header &nbsp;
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi.label')", :value="options.option('bookmarks.points_of_interest')", @toggle="options.toggle('bookmarks.points_of_interest')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi_capital.label')", :value="options.option('bookmarks.capital')", @toggle="options.toggle('bookmarks.capital')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi_mausoleums.label')", :value="options.option('bookmarks.mausoleums')", @toggle="options.toggle('bookmarks.mausoleums')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.poi_towns.label')", :value="options.option('bookmarks.towns')", @toggle="options.toggle('bookmarks.towns')")
          menu-options-menu-option(:label="$translate('ui.menu.options.option.locations.corporation.label')", :value="options.option('bookmarks.corporation')", @toggle="options.toggle('bookmarks.corporation')")

    footer.card-footer
      .card-footer-item.reset-item
        button.button.is-primary.is-medium.is-outlined(@click.stop.prevent='resetOptions' :disabled='!canReset') {{$translate('ui.menu.options.actions.reset')}}
      .card-footer-item.save-item
        button.button.is-primary.is-medium(@click.stop.prevent='saveOptions' :disabled='!isDirty') {{$translate('ui.menu.options.actions.save')}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

interface OptionChoice {
  label: string;
  hint?: string | undefined;
  type: string;
}

const GRAPHICS_OPTIONS: OptionChoice[] = [
  {
    label: 'ui.menu.options.option.graphics.trees.label',
    type: 'renderer.trees'
  },
  {
    label: 'ui.menu.options.option.graphics.buildings.label',
    type: 'renderer.buildings'
  },
  {
    label: 'ui.menu.options.option.graphics.building_animations.label',
    type: 'renderer.building_animations'
  },
  {
    label: 'ui.menu.options.option.graphics.building_effects.label',
    type: 'renderer.building_effects'
  },
  {
    label: 'ui.menu.options.option.graphics.building_anti_alias.label',
    type: 'renderer.building_anti_alias'
  },
  {
    label: 'ui.menu.options.option.graphics.planes.label',
    type: 'renderer.planes'
  },
  {
    label: 'ui.menu.options.option.graphics.webgpu.label',
    hint: 'ui.menu.options.option.graphics.webgpu_hint.label',
    type: 'renderer.webgpu'
  }
];


export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      language_code: this.client_state.options.language() ?? 'EN',

      canReset: this.client_state.options.canReset(),
      isDirty: this.client_state.options.isDirty()
    };
  },

  computed: {
    options () {
      return this.client_state.options;
    },

    optionsGraphics (): OptionChoice[] {
      return GRAPHICS_OPTIONS
    }
  },

  mounted () {
    this.client_state.options?.subscribe_options_listener(() => {
      this.canReset = this.client_state.options.canReset() ?? false;
      this.isDirty = this.client_state.options.isDirty() ?? false;
      this.language_code = this.client_state.options.language() ?? 'EN';
      this.$forceUpdate();
    });
  },

  methods: {
    change_language (code: string): void {
      this.client_state.options.setLanguage(code);
    },
    resetOptions (): void {
      this.client_state.options.reset();
    },
    saveOptions (): void {
      this.client_state.options.save();
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
