<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.tycoon_search.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('tycoon_search')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    template(v-if='hasQuery')
      .sp-section-breadcrumb
        nav.breadcrumb.sp-menu-breadcrumb
          ul
            li
              a(@click.stop.prevent='clearQuery')
                span.sp-breadcrumb-icon
                  font-awesome-icon(:icon="['fas', 'home']")
                span {{ $translate('ui.menu.tycoon_search.breadcrumb') }}

            li.is-active
              a
                span {{ query }}

      aside.sp-scrollbar.container-results
        .sp-menu-loading-container(v-if='querying || !results')
          img.starpeace-logo

        template(v-else-if='results.length')
          menu-shared-toggle-list-menu-item(
            v-for='result in results'
            :key='result.corporationId'
            :client-state='client_state'
            :label="mode=='TYCOONS' ? result.tycoonName : mode=='CORPORATIONS' ? result.corporationName : ''"
            :details-id='result.corporationId'
            :details-callback='load_corporation'
            v-slot:default='slotProps'
          )
            menu-shared-menu-panel-corporation(
              :hide-tycoon="mode=='TYCOONS'"
              :hide-corporation="mode=='CORPORATIONS'"
              :client-state='client_state'
              :tycoon='result'
              :corporation='slotProps.details'
            )

        template(v-else)
          span.empty-results {{ $translate('ui.menu.tycoon_search.results.none') }}

    template(v-else)
      .query-fields
        .tabs.is-centered.is-toggle.is-small.is-fullwidth.sp-tabs.query-mode-toggle
          ul
            li(:class="{'is-active':mode=='CORPORATIONS'}" @click.stop.prevent="swap_mode('CORPORATIONS')")
              a {{ $translate('ui.menu.tycoon_search.toggle.corporation') }}
            li(:class="{'is-active':mode=='TYCOONS'}" @click.stop.prevent="swap_mode('TYCOONS')")
              a {{ $translate('ui.menu.tycoon_search.toggle.tycoon') }}

        form.field.has-addons.query-input(@submit.stop.prevent='query_search')
          p.control.has-icons-left.is-expanded
            input.input(type='text' v-model='query')
            span.icon.is-left
              font-awesome-icon(:icon="['fas', 'search']")
          p.control
            button.button.is-starpeace(@click.stop.prevent='query_search' :disabled='!canQuery') {{$translate('ui.menu.tycoon_search.action.search')}}

        .query-index.is-size-4
          a(v-for='n in 26' @click.stop.prevent='query_prefix(n)') {{String.fromCharCode(65 + n - 1)}}

</template>

<script lang='ts'>
import { type PlanetSearchResult } from '~/plugins/starpeace-client/planet/planets-manager';
import ClientState from '~/plugins/starpeace-client/state/client-state';

declare interface MenuTycoonSearchData {
  mode: string;
  query: string;

  querying: boolean;
  results: Array<PlanetSearchResult> | undefined;
}

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true }
  },

  data (): MenuTycoonSearchData {
    return {
      mode: 'TYCOONS',
      query: '',

      querying: false,
      results: undefined
    };
  },

  computed: {
    ready (): boolean {
      return this.client_state?.workflow_status === 'ready';
    },

    canQuery (): boolean {
      return !this.querying && this.query.length >= 3;
    },
    hasQuery () {
      return this.querying || !!this.results;
    }
  },

  watch: {
    ready () {
      if (!this.ready) {
        this.mode = 'TYCOONS';
        this.query = '';
        this.results = undefined;
      }
    }
  },

  methods: {
    swap_mode (mode: string) {
      this.mode = mode;
      this.query = '';
    },

    clearQuery (): void {
      this.query = '';
      this.results = undefined;
    },

    query_prefix (num: number) {
      this.query = String.fromCharCode(65 + num - 1);
      this.executeQuery(this.query, true)
    },

    query_search () {
      if (!this.canQuery) return;
      this.executeQuery(this.query, false);
    },

    async executeQuery (query: string, queryPrefix: boolean): Promise<void> {
      if (this.querying) {
        return;
      }

      this.querying = true;
      try {
        const queryPromise = this.mode === 'TYCOONS' ? this.$starpeaceClient.managers.planets_manager.search_tycoons(query, queryPrefix) : this.$starpeaceClient.managers.planets_manager.search_corporations(query, queryPrefix);
        this.results = await queryPromise;
      }
      catch (err) {
        this.client_state.add_error_message('Failure loading results from server', err);
      }
      finally {
        this.querying = false;
      }
    },

    load_corporation (corporation_id: string) {
      return this.$starpeaceClient.managers.corporation_manager.load_by_corporation(corporation_id);
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-right / end-right
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: auto
    grid-template-rows: min-content auto

.container-results
  grid-row: 2 / span 1
  overflow-y: scroll

.query-fields
  margin: .5rem

  .query-mode-toggle
    margin-bottom: .5rem

    a
      letter-spacing: .1rem
      text-transform: uppercase

  .query-input
    margin-bottom: 1.5rem

    .button
      letter-spacing: .1rem
      text-transform: uppercase

  .query-index
    display: inline-flex
    flex-wrap: wrap
    margin: .5rem

    a
      margin: 0 .25rem

.empty-results
  margin: 1rem

</style>
