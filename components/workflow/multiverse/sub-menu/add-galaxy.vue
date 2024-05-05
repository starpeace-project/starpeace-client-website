<template lang='pug'>
.add-galaxy-dialog
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{ $translate('ui.workflow.universe.galaxy.add.label') }}
      .card-header-icon.card-close(@click.stop.prevent="closeMenu")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background.p-0
      form(method='dialog' @submit.prevent='addGalaxy')
        .field.is-horizontal
          .field-label.is-normal
            label.label Protocol:
          .field-body
            .field
              .control
                button.button.is-medium.is-fullwidth(type='button' :class="{'is-active': protocol == 'http'}" @click.stop.prevent='toggleHttp') HTTP
            .field
              .control
                button.button.is-medium.is-fullwidth(type='button' :class="{'is-active': protocol == 'https'}" @click.stop.prevent='toggleHttps') HTTPS

        .field.is-horizontal
          .field-label.is-normal
            label.label Host / IP:
          .field-body
            .field
              .control
                input.input.is-dark-border(type='text' ref='host' v-model='host')

        .field.is-horizontal
          .field-label.is-normal
            label.label Port:
          .field-body
            .field
              .control
                input.input.is-dark-border(type='number' placeholder='19160' v-model='port')

      .galaxy-actions.is-flex.mt-4
        button.button.is-medium.is-flex-grow-1(type='reset' @click.stop.prevent='closeMenu') {{ $translate('misc.action.cancel') }}
        button.button.is-medium.is-flex-grow-1(type='submit' @click.stop.prevent='addGalaxy' :disabled='!canSubmit') {{ $translate('misc.action.add') }}


</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data () {
    return {
      protocol: 'http',
      host: '',
      port: ''
    };
  },

  computed: {
    port_as_number (): number {
      try {
        const value: number = parseInt(this.port);
        return isNaN(value) || !isFinite(value) ? 0 : value;
      }
      catch {
        return 0;
      }
    },

    canSubmit (): boolean {
      return (this.protocol === 'http' || this.protocol === 'https') && this.host?.length > 0 && this.port_as_number > 0;
    }
  },

  mounted () {
    if (this.$refs.host) {
      (this.$refs.host as any).focus();
    }
  },

  methods: {
    closeMenu (): void {
      this.clientState.interface?.hide_add_galaxy();
    },

    toggleHttp (): void {
      this.protocol = 'http';
    },
    toggleHttps (): void {
      this.protocol = 'https';
    },

    addGalaxy (): void {
      if (!this.canSubmit) {
        return;
      }

      const galaxy = this.clientState.options.galaxy.add_galaxy(this.protocol, this.host, this.port_as_number);
      this.clientState.core.galaxy_cache.loadGalaxyConfiguration(galaxy.id, galaxy);
      this.clientState.interface.hide_add_galaxy();
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities'
@import '~/assets/stylesheets/starpeace-variables'

.add-galaxy-dialog
  position: fixed
  left: calc(50% - 20rem)
  width: 40rem
  height: 16rem
  top: calc(50% - 8rem - 3rem)
  z-index: 2000

  .card
    height: 100%

  .galaxies-container
    height: calc(100% - 3rem)
    overflow-y: scroll
    padding: 1rem

    > .columns
      margin: 0

      > .column
       padding: .5rem

  form
    padding: .5rem

  .select-galaxy-toggle
    cursor: pointer

  .galaxy-name
    font-size: 1.25rem
    cursor: pointer

</style>
