<template lang='pug'>
#toolbar-header(v-show='is_ready' v-cloak=true :oncontextmenu="'return ' + !$config.public.disableRightClick")
  .columns.row-menu
    .column.column-menu
      .toolbar-menu
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('galaxy')}" @click.stop.prevent="toggle_menu('galaxy')" :data-tooltip="$translate('ui.menu.galaxy.header')")
          font-awesome-icon(:icon="['fas', 'satellite']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('bookmarks')}" @click.stop.prevent="toggle_menu('bookmarks')" :data-tooltip="$translate('ui.menu.bookmarks.header')")
          font-awesome-icon(:icon="['fas', 'map-marker-alt']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('tycoon')}" @click.stop.prevent='toggle_tycoon_details' :data-tooltip="$translate('ui.menu.tycoon_details.header')" :disabled='!is_tycoon')
          font-awesome-icon(:icon="['fas', 'user-tie']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('politics')}" @click.stop.prevent="toggle_menu('politics')" :data-tooltip="$translate('ui.menu.politics.header')")
          font-awesome-icon(:icon="['fas', 'landmark']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('rankings')}" @click.stop.prevent="toggle_menu('rankings')" :data-tooltip="$translate('ui.menu.rankings.header')")
          font-awesome-icon(:icon="['fas', 'medal']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('hide_all')}" @click.stop.prevent="toggle_menu('hide_all')" :data-tooltip="$translate('misc.hide_menus.label')")
          font-awesome-icon(:icon="['far', 'eye']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('town_search')}" @click.stop.prevent="toggle_menu('town_search')" :data-tooltip="$translate('ui.menu.town_search.header')")
          font-awesome-icon(:icon="['fas', 'search-location']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('tycoon_search')}" @click.stop.prevent="toggle_menu('tycoon_search')" :data-tooltip="$translate('ui.menu.tycoon_search.header')")
          font-awesome-icon(:icon="['fas', 'search']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('research')}" @click.stop.prevent="toggle_menu('research')" :data-tooltip="$translate('ui.menu.research.header')")
          font-awesome-icon(:icon="['fas', 'flask']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('construction')}" @click.stop.prevent="toggle_menu('construction')" :data-tooltip="$translate('ui.menu.construction.header')")
          font-awesome-icon(:icon="['fas', 'hammer']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('mail')}" @click.stop.prevent="toggle_menu('mail')" :data-tooltip="$translate('ui.menu.mail.header')")
          font-awesome-icon(:icon="['far', 'envelope']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('chat')}" @click.stop.prevent="toggle_menu('chat')" :data-tooltip="$translate('ui.menu.chat.header')")
          font-awesome-icon(:icon="['far', 'comments']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('options')}" @click.stop.prevent="toggle_menu('options')" :data-tooltip="$translate('ui.menu.options.header')")
          font-awesome-icon(:icon="['fas', 'cogs']")
        button.button.is-starpeace.is-small.has-tooltip-arrow(:class="{'is-active':is_menu_visible('help')}" @click.stop.prevent="toggle_menu('help')" :data-tooltip="$translate('ui.menu.help.header')")
          font-awesome-icon(:icon="['far', 'question-circle']")

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
    is_menu_visible (option_type: string) { return this.client_state.menu.is_visible(option_type); },
    toggle_menu (option_type: string) {
      if (option_type === 'hide_all' && this.client_state.interface.show_inspect) {
        this.client_state.interface.hide_inspect();
      }
      this.client_state.menu.toggle_menu(option_type);
    },

    toggle_tycoon_details () {
      if (!this.client_state.is_tycoon()) return;
      if (this.client_state.menu.is_visible('tycoon')) {
        this.client_state.menu.toggle_menu('tycoon');
      }
      else {
        this.client_state.show_tycoon_profile(this.client_state.player.tycoon_id);
      }
    },

    toggle_mail () {
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

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

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

.toolbar-menu
  background: linear-gradient(to top, darken($sp-primary-bg, 5%), #06261D)
  display: inline-block
  padding: .25rem
  text-align: center
  width: 46rem

  .button
    height: 2.5rem
    font-size: 1.25rem
    padding: 0 .65rem

    &.is-starpeace
      &.is-small
        border-radius: .2rem
        height: 2.5rem
        font-size: 1.25rem
        line-height: 1.5
        padding: 0 .65rem

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
