<template lang='pug'>
client-only
  transition(name='fade-in')
    #workflow-container(v-if='is_active')
      .card.is-starpeace(:style='workflow_card_style' :class='workflow_card_class')
        .card-header(v-show='has_header')
          .card-header-title.card-header-planet(v-show="status == 'pending_planet'")
            a(v-on:click.stop.prevent='reset_galaxy') {{$translate('ui.workflow.universe.multiverse.label')}}
            span.title-spacer /
            span.planet-name {{ current_galaxy_name }}

        .card-content
          workflow-loading(v-if="status == 'initializing'" :message="$translate('ui.workflow.loading.initializing')")

          workflow-universe(v-else-if="status == 'pending_universe'" :ajax_state='client_state.ajax_state' :client_state='client_state')
          workflow-planet(v-else-if="status == 'pending_planet'" :client_state='client_state')
          workflow-loading(v-else-if="status == 'pending_visa'" :message="$translate('ui.workflow.loading.pending_visa')")
          workflow-loading(v-else-if="status == 'pending_assets'" :message="$translate('ui.workflow.loading.pending_assets')")
          workflow-loading(v-else-if="status == 'pending_planet_details'" :message="$translate('ui.workflow.loading.pending_planet_details')")
          workflow-loading(v-else-if="status == 'pending_player_data'" :message="$translate('ui.workflow.loading.pending_player_data')")
          workflow-loading(v-else-if="status == 'pending_initialization'" :message="$translate('ui.workflow.loading.pending_initialization')")
          workflow-loading(v-else-if="status == 'ready'" :message="$translate('ui.workflow.loading.initializing')")

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

const STATUS_MAX_WIDTHS: Record<string, string> = {
  'pending_universe': '70rem',
  'pending_visa': '20rem',
  'pending_planet': '80rem',
  'pending_assets': '20rem',
  'pending_initialization': '20rem'
};

export default {
  props: {
    client_state: { type: ClientState, required: true },
  },

  computed: {
    status (): string { return this.client_state.workflow_status; },
    is_active (): boolean { return this.status !== 'ready'; },

    workflow_card_class () {
      return {
        'has-header': this.has_header,
        'full-height': this.status === 'pending_universe',
        'sp-scrollbar': this.status === 'pending_planet'
      };
    },
    workflow_card_style () {
      return {
        'width': this.max_width, 'max-height': this.max_height
      };
    },

    has_header (): boolean { return this.status === 'pending_planet'; },
    max_width (): string { return STATUS_MAX_WIDTHS[this.status] ?? 'inherit'; },
    max_height (): string { return this.status === 'pending_universe' ? '60rem' : 'inherit'; },

    current_galaxy_name (): string | undefined {
      if (!this.client_state.identity.galaxy_id) return undefined;
      return this.client_state.core.galaxy_cache.metadataForGalaxyId(this.client_state.identity.galaxy_id)?.name;
    }
  },

  methods: {
    reset_galaxy (): void {
      this.client_state.identity.reset_state();
      this.client_state.update_state();
      if (window?.document) window.document.title = "STARPEACE"
    }
  }
}
</script>

<style lang='sass' scoped>
#workflow-container
  align-items: center
  display: flex
  flex-direction: column
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: start-render
  grid-row-end: end-toolbar
  margin: 0
  max-height: 100%
  justify-content: center
  overflow: hidden
  position: relative

.existing-corporations
  margin-bottom: 1rem

.card
  display: inline-block
  overflow: hidden
  position: relative
  text-align: left
  transition: max-width .5s
  z-index: 1050

  &.sp-scrollbar
    overflow-y: auto

  .card-header-planet
    .title-spacer
      font-weight: normal
      margin: 0 .75rem

    a
      color: #fff
      font-weight: normal

  .card-content
    height: 100%
    position: relative
    transition: width .5s

  &.has-header
    .card-content
      height: calc(100% - 3rem)

  &.full-height
    height: calc(100% - 2rem)

</style>
