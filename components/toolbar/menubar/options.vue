<template lang='pug'>
.toolbar-menu
  template(v-for='option in options')
    button.button.is-menu-option.is-small.has-tooltip-arrow(
      :class="{'is-active': visibleByOptionId[option.id]}"
      :data-tooltip='$translate(option.label)'
      @click.stop.prevent='toggleMenu(option.id)'
    )
      font-awesome-icon(:icon='option.icons')

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

interface MenuOption {
  id: string;
  icons: Array<string>;
  label: string;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  computed: {
    isTycoon (): boolean {
      return this.clientState.initialized && this.clientState?.workflow_status === 'ready' && this.clientState?.is_tycoon();
    },

    options (): Array<MenuOption> {
      return [
        {
          id: 'galaxy',
          icons: ['fas', 'satellite'],
          label: 'ui.menu.galaxy.header'
        },
        {
          id: 'bookmarks',
          icons: ['fas', 'map-marker-alt'],
          label: 'ui.menu.bookmarks.header'
        },
        {
          id: 'tycoon',
          icons: ['fas', 'user-tie'],
          label: 'ui.menu.tycoon_details.header'
        },
        {
          id: 'politics',
          icons: ['fas', 'landmark'],
          label: 'ui.menu.politics.header'
        },
        {
          id: 'rankings',
          icons: ['fas', 'medal'],
          label: 'ui.menu.rankings.header'
        },
        {
          id: 'hide_all',
          icons: ['far', 'eye'],
          label: 'misc.hide_menus.label'
        },
        {
          id: 'town_search',
          icons: ['fas', 'search-location'],
          label: 'ui.menu.town_search.header'
        },
        {
          id: 'tycoon_search',
          icons: ['fas', 'search'],
          label: 'ui.menu.tycoon_search.header'
        },
        {
          id: 'research',
          icons: ['fas', 'flask'],
          label: 'ui.menu.research.header'
        },
        {
          id: 'construction',
          icons: ['fas', 'hammer'],
          label: 'ui.menu.construction.header'
        },
        {
          id: 'mail',
          icons: ['far', 'envelope'],
          label: 'ui.menu.mail.header'
        },
        {
          id: 'chat',
          icons: ['far', 'comments'],
          label: 'ui.menu.chat.header'
        },
        {
          id: 'options',
          icons: ['fas', 'cogs'],
          label: 'ui.menu.options.header'
        },
        {
          id: 'help',
          icons: ['far', 'question-circle'],
          label: 'ui.menu.help.header'
        }
      ]
    },

    visibleByOptionId (): Record<string, boolean> {
      return Object.fromEntries(this.options.map(o => [o.id, this.clientState.menu.is_visible(o.id)]));
    }
  },

  methods: {
    toggleMenu (optionType: string): void {
      if (optionType === 'tycoon') {
        if (this.clientState.menu.is_visible('tycoon')) {
          this.clientState.menu.toggle_menu('tycoon');
        }
        else if (this.isTycoon && this.clientState.player.tycoon_id) {
          this.clientState.show_tycoon_profile(this.clientState.player.tycoon_id);
        }
      }
      else {
        if (optionType === 'hide_all' && this.clientState.interface.show_inspect) {
          this.clientState.interface.hide_inspect();
        }
        this.clientState.menu.toggle_menu(optionType);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

@keyframes opacity-blink
  0%
    opacity: .5
  25%
    opacity: 1
  75%
    opacity: 1
  100%
    opacity: .5

.toolbar-menu
  background: linear-gradient(to top, darken($sp-primary-bg, 5%), #06261D)
  display: inline-block
  padding: .25rem
  text-align: center
  width: 46rem

  .button
    &:first-child
      &.has-tooltip-arrow
        &.is-tooltip-active::before,
        &:focus::before,
        &:hover::before
          left: 75%

    &:not(:first-child)
      margin-left: .5rem

    &.has-tooltip-arrow
      &.is-tooltip-active::before,
      &:focus::before,
      &:hover::before
        z-index: 1200

</style>
