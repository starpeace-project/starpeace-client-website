<template lang='pug'>
.galaxy-row.is-flex.is-flex-direction-row.is-align-items-center.p-2
  .is-flex-grow-1
    h3.galaxy-name(:class="{'is-smaller': galaxyInfo.nameLong }")
      .galaxy-name-text {{ galaxyInfo.name }}

  .is-flex-shrink-1
    .galaxy-planets
      span.planet-label {{ $translate('ui.menu.galaxy.details.planets.label') }}:
      span.planet-value {{ galaxyInfo.planetCount }}
    .galaxy-online
      span.planet-label {{ $translate('ui.menu.galaxy.details.online.label') }}:
      span.planet-value {{ galaxyInfo.onlineCount }}

  .is-flex-shrink-1.has-text-right.ml-6
    button.button.is-medium.is-primary.is-outlined(:disabled='!canSelectVisitor' @click.stop.prevent='proceedAsVisitor') {{ $translate('identity.visitor') }}
    button.button.is-medium.is-primary.ml-2(:class="{'is-outlined': !isTycoonSelected}" :disabled='!canSelectTycoon' @click.stop.prevent='selectGalaxy') {{ $translate('identity.tycoon') }}

  .galaxy-loading-modal(v-if='galaxyInfo.loading || galaxyInfo.hasError')
    img.starpeace-logo(v-if='galaxyInfo.loading')
    .galaxy-error-message(v-if='galaxyInfo.hasError')
      span {{ $translate('misc.unable_to_connect.label') }}
      a(@click.stop.prevent='refreshGalaxy') {{ $translate('misc.try_again.label') }}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';
import GalaxyConfiguration from '~/plugins/starpeace-client/galaxy/galaxy-configuration';

export default {
  props: {
    clientState: { type: ClientState, required: true },
    ajaxState: { type: Object, required: true },

    galaxy: { type: GalaxyConfiguration, required: true },
    galaxyInfo: { type: Object, required: true },

    selectedGalaxyId: { type: String, required: false }
  },

  computed: {
    canSelectVisitor (): boolean {
      return !!this.galaxyInfo.visitorIssueEnabled;
    },

    canSelectTycoon (): boolean {
      return !!this.galaxyInfo.tycoonIssueEnabled;
    },
    isTycoonSelected (): boolean {
      return this.selectedGalaxyId === this.galaxy.id;
    }
  },

  methods: {
    refreshGalaxy (): void {
      this.$emit('refresh-galaxy', this.galaxy.id);
    },
    selectGalaxy (): void {
      this.$emit('select-galaxy', this.galaxy.id);
    },
    proceedAsVisitor () {
      if (this.canSelectVisitor) {
        this.$emit('login-visitor', this.galaxy.id);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.galaxy-row
  background-color: opacify(lighten($sp-primary-bg, 1%), .3)
  border: 1px solid rgba(110, 161, 146, .2)
  color: #fff
  position: relative

  &:not(:first-child)
    margin-top: .25rem

  .galaxy-name-text
    overflow: hidden
    text-overflow: ellipsis
    white-space: nowrap

  .is-smaller
    font-size: 1.25rem

  .planet-label
    display: inline-block
    min-width: 4rem
    text-align: right

  .planet-value
    margin-left: .75rem

  .galaxy-loading-modal
    background-color: #000
    border: 1px solid #000
    height: calc(100% + 2px)
    left: -1px
    opacity: .85
    position: absolute
    top: -1px
    width: calc(100% + 2px)

    .starpeace-logo
      animation: spin-and-blink 1.5s linear infinite
      background-size: 2rem
      filter: $sp-filter-primary
      height: 2rem
      left: calc(50% - 1rem)
      opacity: .7
      position: absolute
      top: calc(50% - 1rem)
      width: 2rem

    .galaxy-error-message
      font-size: 1.1rem
      left: calc(50% - 20rem)
      position: absolute
      text-align: center
      top: calc(50% - 1rem)
      width: 40rem

      a
        margin-left: .5rem

</style>
