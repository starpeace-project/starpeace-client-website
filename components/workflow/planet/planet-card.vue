<template lang='pug'>
.cell.planet
  article.box.planet-row
    .is-flex.is-flex-direction-row.is-align-items-center
      .planet-image
        template(v-if='false')
          img.starpeace-logo.logo-loading(:src='planetAnimationUrl' @load='finishImageLoading')
        template(v-else)
          img.starpeace-logo.logo-loading

      .planet-item.info.is-flex-grow-1
        .planet-name {{ planet.name }}
        .planet-population.planet-info-row
          span {{ $translate('ui.menu.galaxy.details.population.label') }}:
          span.planet-value {{ planet.population || 0 }}
        .planet-investments.planet-info-row
          span {{ $translate('ui.menu.galaxy.details.investments.label') }}:
          span.planet-value
            misc-money-text(:value='planet.investment_value')
        .planet-tycoons.planet-info-row
          span {{ $translate('ui.menu.galaxy.details.corporations.label') }}:
          span.planet-value {{ planet.corporation_count || 0 }}
        .planet-online.planet-info-row
          span {{ $translate('ui.menu.galaxy.details.online.label') }}:
          span.planet-value {{ planet.onlineCount || 0 }}

    .is-flex.is-flex-direction-row.mt-2
      button.button.is-primary.is-outlined.mr-2(type='button' @click.stop.prevent='selectVisitor' :disabled='!isVisitorEnabled') {{ $translate('identity.visitor') }} {{ $translate('identity.visa') }}
      button.button.is-primary.is-flex-grow-1(type='submit' ref='submitAction' :autofocus='mainPlanet' :class="{'is-outlined': !corporationIdentifier}" @click.stop.prevent='selectTycoon' :disabled='!isTycoonEnabled')
        .action-text(v-if='isLoading') {{ $translate('ui.workflow.loading') }}
        .action-text(v-else-if='corporationIdentifier') {{ corporationIdentifier.name }}
        .action-text(v-else) {{ $translate('ui.menu.corporation.establish.action.establish') }}

  .disabled-overlay(v-if='isLoading')
    .disabled-text {{ $translate('ui.workflow.loading') }}

  .disabled-overlay(v-else-if='!planet.enabled')
    .disabled-text {{ $translate('ui.menu.galaxy.planet_not_available.label') }}

</template>

<script lang='ts'>
import _ from 'lodash';

import Planet from '~/plugins/starpeace-client/planet/planet';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true },
    planet: { type: Planet, required: true },

    isLoading: { type: Boolean, required: true },
    mainPlanet: { type: Boolean, required: false },
    hasTycoon: { type: Boolean, required: true },
    corporationIdentifier: { type: Object, required: false }
  },

  computed: {
    planetAnimationUrl (): string {
      return this.$starpeaceClient.managers.asset_manager.planet_animation_url(this.planet);
    },

    isVisitorEnabled (): boolean {
      return false && this.planet.enabled && !this.isLoading;
    },
    isTycoonEnabled (): boolean {
      return this.hasTycoon && this.planet.enabled && !this.isLoading;
    },
  },

  mounted () {
    if (this.mainPlanet && this.$refs.submitAction) {
      (this.$refs.submitAction as any).focus();
    }
  },

  methods: {
    finishImageLoading (event: any): void {
      if (event?.target?.classList) {
        event.target.classList.remove('starpeace-logo', 'logo-loading');
      }
    },

    selectVisitor (): void {
      if (this.isVisitorEnabled && !this.isLoading) {
        this.$emit('select-visitor', this.planet);
      }
    },

    selectTycoon (): void {
      if (this.isTycoonEnabled && !this.isLoading) {
        this.$emit('select-tycoon', this.planet);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.disabled-overlay
  background-color: #000
  border: 1px solid rgba(8, 59, 44, .8)
  cursor: not-allowed
  height: calc(100% + 2px)
  left: -1px
  opacity: .85
  position: absolute
  text-align: center
  top: -1px
  width: calc(100% + 2px)

  .disabled-text
    color: #ddd
    font-size: 1.25rem
    font-style: italic
    left: calc(50% - 10rem)
    position: absolute
    top: calc(50% - 1rem)
    width: 20rem

.cell
  &.planet
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    margin: .25rem
    padding: 0
    position: relative

    &.is-empty
      opacity: 0

    .columns
      margin: 0

    .planet-row
      .logo-loading
        background-size: 7.5rem
        height: 7.5rem
        width: 7.5rem

      .planet-image
        padding-right: .4rem

        img
          background-size: 7.5rem
          height: 7.5rem
          width: 7.5rem

      .planet-item
        color: #fff
        padding-left: .4rem

        &.description
          padding-left: 1rem
          margin-right: 2rem
          max-width: 14rem

        .planet-info-row
          border-bottom: 1px solid darken($sp-primary, 10%)
          padding-bottom: .25rem
          margin-bottom: .25rem

        .planet-name
          font-size: 1.5rem
          font-weight: 1000
          margin-bottom: .25rem

        .planet-value
          margin-left: .5rem

.action-text
  overflow: hidden
  text-overflow: ellipsis
  white-space: nowrap

</style>
