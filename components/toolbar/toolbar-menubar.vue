<template lang='pug'>
#toolbar-header(v-show='is_ready' v-cloak=true :oncontextmenu="'return ' + !$config.public.disableRightClick")
  .columns.row-menu
    .column.column-menu
      toolbar-menubar-options(
        :client-state='client_state'
      )

    .column.column-tycoon
      span.column-tycoon-name
        template(v-if='is_tycoon')
          | {{tycoon_name}}
        template(v-else-if='!is_tycoon')
          | {{$translate('identity.visitor')}}

      span.column-tycoon-buildings
        span.count {{ buildingCount }} / {{ maxBuildingCount }}
        font-awesome-icon(:icon="['far', 'building']")

      .column-notification-icons.level
        .level-item.client-version
          a(:class='menu_class_release_notes' @click.stop.prevent="client_state.menu.toggle_menu('release_notes')") {{client_version}}

        template(v-if='show_game_music')
          .level-item.game-music(:class='game_music_class')
            font-awesome-icon(:icon="['fas', 'play']" v-show='!game_music_playing' @click.stop.prevent='music_state.toggleMusic()')
            font-awesome-icon(:icon="['fas', 'pause']" v-show='game_music_playing' @click.stop.prevent='music_state.toggleMusic()')
          .level-item.game-music-next(:class='game_music_volume_class')
            font-awesome-icon(:icon="['fas', 'fast-forward']" @click.stop.prevent='music_state.nextSong()')
          .level-item.game-music-volume(:class='game_music_volume_class')
            font-awesome-icon(:icon="['fas', 'volume-up']" v-show='music_state.gameMusicVolume' @click.stop.prevent='music_state.toggleVolume()')
            font-awesome-icon(:icon="['fas', 'volume-off']" v-show='!music_state.gameMusicVolume' @click.stop.prevent='music_state.toggleVolume()')

        .level-item.notification-mail(:class="{'has-unread':unread_mail.length>0}" @click.stop.prevent='toggle_mail()')
          font-awesome-icon(:icon="['far', 'envelope']")

        .level-item.notification-loading
          img.starpeace-logo(:class='notification_loading_css_class')

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      client_version: this.$config.public.CLIENT_VERSION,
      show_game_music: this.client_state.options?.option('music.show_game_music')
    };
  },

  computed: {
    music_state () { return this.client_state?.music; },

    is_ready () { return this.client_state.initialized && this.client_state?.workflow_status === 'ready'; },
    is_tycoon () { return this.is_ready && this.client_state?.is_tycoon(); },

    unread_mail () { return _.filter(_.values(this.client_state.player.mail_by_id), (m) => !m.read); },

    menu_class_release_notes () {
      return {
        'is-active': this.client_state?.menu?.is_visible('release_notes') ?? false
      };
    },

    game_music_playing () { return this.music_state.gameMusicPlaying; },
    game_music_class () { return this.music_state.gameMusicPlaying ? 'music-pause' : 'music-play'; },
    game_music_volume_class () { return this.music_state.gameMusicVolume ? 'music-volume' : 'music-mute'; },

    notification_loading_css_class () {
      return {
        'ajax-loading': (this.ajax_state?.ajaxRequests ?? 0) > 0
      };
    },

    tycoon_name () { return this.is_tycoon ? this.client_state?.identity?.galaxy_tycoon_name : ''; },

    maxBuildingCount (): number {
      if (this.is_tycoon && this.client_state.player.corporation_id) {
        const corporation = this.client_state.core.corporation_cache.metadata_for_id(this.client_state.player.corporation_id);
        const level = corporation ? this.client_state.core.planet_library.level_for_id(corporation.levelId) : undefined;
        if (level) {
          return level.facilityLimit ?? 0;
        }
      }
      return 0;
    },
    buildingCount (): number {
      if (this.is_tycoon) {
        return (this.client_state.corporation.company_ids ?? []).map((id: string) => {
          return (this.client_state.corporation.buildings_ids_by_company_id?.[id] ?? []).length;
        }).reduce((sum: number, val: number) => sum + val, 0);
      }
      return 0;
    }
  },

  mounted () {
    this.client_state.options?.subscribe_options_listener(() => {
      this.show_game_music = this.client_state.options?.option('music.show_game_music');
    });
  },

  methods: {
    toggle_mail (): void {
      if (!this.unread_mail.length) return;
      this.client_state.menu.toggle_menu('mail');
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


#toolbar-header
  grid-column: start-left / end-right
  grid-row: start-menu / end-menu
  margin: 0
  position: relative
  pointer-events: auto

  .row-menu
    margin: 0

    .column-menu
      padding: 0
      max-width: 46rem

  .column-tycoon
    background: linear-gradient(to right, #395950, #000)
    padding: .5rem .75rem
    vertical-align: middle

    .column-tycoon-name
      color: #fff
      font-size: 1.25rem
      font-weight: 1000
      line-height: 1.8rem
      margin-right: 1rem
      vertical-align: bottom

    .column-tycoon-buildings
      color: $sp-primary

      .count
        margin-right: .5rem

    .column-notification-icons
      float: right

      .client-version
        font-style: italic

        a
          color: #6ea192
          opacity: .5

          &:hover
            color: #6ea192
            opacity: .7

          &:active,
          &.is-active
            color: #6ea192
            opacity: 1

      .game-music
        color: $sp-primary
        cursor: pointer
        font-size: 1.2rem
        margin-left: 1.5rem

        &.music-pause
          opacity: .5

        &.music-play
          opacity: .8

      .game-music-next
        color: $sp-primary
        cursor: pointer
        font-size: 1.5rem
        margin-left: .75rem
        opacity: .5

      .game-music-volume
        color: $sp-primary
        cursor: pointer
        font-size: 1.5rem
        margin-left: .5rem
        min-width: 1.75rem
        opacity: .5

      .notification-mail
        color: $sp-primary
        font-size: 1.5rem
        margin-left: 1rem
        opacity: .5

        &.has-unread
          animation: opacity-blink 3s linear infinite
          cursor: pointer

      .notification-loading
        margin-left: .75rem
        opacity: .5
        position: relative
        z-index: 1500 /* higher than others for animation */

        .starpeace-logo
          filter: invert(38%) sepia(9%) saturate(1145%) hue-rotate(112deg) brightness(101%) contrast(86%)
          background-size: 1.4rem
          height: 1.4rem
          width: 1.4rem
          vertical-align: middle

          &.ajax-loading
            animation: spin 1.5s linear infinite

</style>
