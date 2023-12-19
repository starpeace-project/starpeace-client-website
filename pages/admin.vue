<template lang='pug'>
client-only
  #application-container
    page-layout-header(:client_state='clientState')

    #application-body
      .columns

        template(v-if='!tycoon')
          .column.is-offset-4.is-4
            .card.is-starpeace
              .card-content.has-text-white
                .is-flex.is-flex-direction-row.is-align-items-center
                  .select.is-medium.galaxy-options
                    select(:disabled='!!authorizing' v-model='galaxyId')
                      option(v-for='galaxy in sortedGalaxies' :value='galaxy.id') {{ galaxyNameById[galaxy.id] }}

                .is-flex.is-flex-direction-row.mt-3
                  .is-flex-grow-1.pr-1.control.has-icons-left.is-expanded
                    input.input(type='text' autocomplete='username' placeholder="Username" v-model='username' :disabled='!!authorizing')
                    span.icon.is-small.is-left
                      font-awesome-icon(:icon="['fas', 'user-tie']")
                  .is-flex-grow-1.pr-2.control.has-icons-left.is-expanded
                    input.input(type='password' autocomplete='current-password' :placeholder="$translate('ui.workflow.universe.password.label')" v-model='password' :disabled='!!authorizing')
                    span.icon.is-small.is-left
                      font-awesome-icon(:icon="['fas', 'lock']")
                  .is-flex-grow-0.control
                    button.button.is-starpeace.px-5(:disabled='!canSignIn' @click.stop.prevent='doSignIn') Sign In

        template(v-else-if='isAllowed')
          .column.is-2
            .card.is-starpeace
              .card-content

          .column.is-8
            .card.is-starpeace
              .card-header
                .card-header-title Admin
              .card-content
                | Welcome, admin or game master!

        template(v-else)
          .column.is-offset-4.is-4
            .card.is-starpeace
              .card-content.has-text-white.is-size-4.has-text-centered
                | Sorry, only admin or game masters are allowed access.

    page-layout-footer
</template>

<script lang='ts'>
import _ from 'lodash';

import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon';
import ClientState from '~/plugins/starpeace-client/state/client-state';

definePageMeta({
  layout: 'release'
})

declare interface AdminData {
  galaxies: Array<any>;

  authorizing: boolean;
  galaxyId: string | undefined;
  username: string;
  password: string;

  tycoon: Tycoon | undefined;
}

export default {
  data (): AdminData {
    const galaxies = this.$starpeaceClient?.client_state.options.get_galaxies() ?? [];
    return {
      galaxies: galaxies,

      authorizing: false,
      galaxyId: galaxies.length ? galaxies[0].id : undefined,
      username: '',
      password: '',

      tycoon: undefined,
    };
  },

  computed: {
    clientState (): ClientState {
      return this.$starpeaceClient?.client_state;
    },

    sortedGalaxies (): Array<any> {
      return _.orderBy(this.galaxies, [(g) => this.galaxyNameById[g.id]], ['asc']);
    },

    galaxyNameById (): Record<string, string> {
      return Object.fromEntries(this.galaxies.map((g: any) => {
        const metadata = this.clientState.core.galaxy_cache.galaxy_metadata(g.id);
        return [g.id, metadata ? metadata.name : `${g.api_url}:${g.api_port}`];
      }));
    },

    canSignIn (): boolean {
      return _.trim(this.username).length > 0 && _.trim(this.password).length > 0 && (this.galaxyId?.length ?? 0) > 0 && !this.authorizing;
    },

    isAllowed (): boolean {
      return !!this.tycoon?.admin || !!this.tycoon?.gameMaster;
    }
  },

  watch: {
    galaxies: {
      immediate: true,
      handler () {
        this.refreshGalaxies();
      }
    }
  },

  methods: {
    async refreshGalaxies () {
      await Promise.all(this.galaxies.map((galaxy) => {
        return this.$starpeaceClient.managers.galaxy_manager.load_metadata(galaxy.id)
          .then((metadata: Galaxy) => {
            if (galaxy.id !== metadata.id) {
              this.clientState.options.change_galaxy_id(galaxy.id, metadata.id);
              this.clientState.core.galaxy_cache.change_galaxy_id(galaxy.id, metadata.id);
            }
          })
          .catch((e: Error) => {
            console.error(e);
          });
      }));
    },

    async doSignIn (): Promise<void> {
      if (this.canSignIn) {
        this.authorizing = true;
        try {
          const tycoon: Tycoon = await this.$starpeaceClient.managers.galaxy_manager.login(this.galaxyId, this.username, this.password, false);
          this.username = '';
          this.password = '';
          this.authorizing = false;
          this.tycoon = tycoon;
        }
        catch (err) {
          console.error(err);
          this.authorizing = false;
        }
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'

#application-body
  +mobile
    overflow-x: hidden

.galaxy-options
  width: 100%

  select
    width: 100%

</style>
