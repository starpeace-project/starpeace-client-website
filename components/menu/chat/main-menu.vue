<template lang='pug'>
.card.is-starpeace.has-header.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.chat.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('chat')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    .section-discord
      | {{$translate('ui.menu.chat.discord.prefix')}}
      |
      a.header-item.discord(href='https://discord.gg/TF9Bmsj', target='_blank') Discord
      |
      | {{$translate('ui.menu.chat.discord.suffix')}}

    aside.sp-scrollbar.container-results
      .sp-menu-loading-container(v-if='loading || !onlineTycoons')
        img.starpeace-logo

      template(v-else-if='sortedTycoons.length')
        menu-shared-toggle-list-menu-item(
          v-for='(tycoon,index) in sortedTycoons'
          :key='tycoon.corporationId || index'
          :client-state='client_state'
          :label='tycoon.tycoonName'
          :details-id='tycoon.corporationId'
          :details-callback="tycoon.type == 'visitor' ? null : loadCorporation"
          v-slot:default='slotProps'
        )
          menu-shared-menu-panel-corporation(
            hide-tycoon
            :client-state='client_state'
            :tycoon='tycoon'
            :corporation='slotProps.details'
          )

      template(v-else)
        .none-container {{$translate('ui.misc.none')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon';

declare interface MainMenuData {
  visible: boolean;
  onlinePromise: Promise<any> | null;
  onlineTycoons: Array<Tycoon> | null;
}

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data (): MainMenuData {
    return {
      visible: this.client_state?.menu?.is_visible('chat'),
      onlinePromise: null,
      onlineTycoons: null
    };
  },

  computed: {
    loading () { return false; },
    sortedTycoons (): Array<Tycoon> {
      return _.orderBy(_.map(this.onlineTycoons, (tycoon) => {
        if (tycoon.type === 'visitor') {
          tycoon.tycoonName = this.$translate('identity.visitor');
          tycoon.corporationId = tycoon.tycoonId;
        }
        return tycoon;
      }), ['tycoonName'], ['asc']);
    }
  },

  mounted () {
    this.client_state?.menu?.subscribe_menu_listener(() => {
      this.visible = this.client_state?.menu?.is_visible('chat');
    });
  },

  watch: {
    visible () {
      if (this.visible) {
        this.refreshTycoons();
      }
      else {
        this.onlineTycoons = null;
      }
    }
  },

  methods: {
    loadCorporation (corporationId: string) {
      this.$starpeaceClient.managers.corporation_manager.load_by_corporation(corporationId);
    },

    async refreshTycoons () {
      try {
        this.onlinePromise = this.$starpeaceClient.managers.planets_manager.load_online_tycoons(this.client_state.player.planet_id);
        this.onlineTycoons = await this.onlinePromise;
        this.onlinePromise = null
      }
      catch (err) {
        this.onlinePromise = null;
        this.client_state.add_error_message('Failure loading online tycoons from server', err);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-variables'

.sp-menu
  grid-column: start-right / end-right
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: auto
    grid-template-rows: min-content min-content auto

.container-results
  grid-row: 3 / span 1
  overflow-y: scroll

.section-discord
  padding: .5rem

.none-container
  padding: .5rem

</style>
