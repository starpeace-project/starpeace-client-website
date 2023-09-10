<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.rankings.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('rankings')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    aside.sp-scrollbar.container-ranking-type(v-if='!selected_ranking_type')
      menu-rankings-ranking-type-node(
        v-for='node in ranking_nodes'
        :node='node'
        :level='0'
        :key='node.id'
        @select='select_ranking_type'
      )

    template(v-else)
      .sp-section-breadcrumb
        nav.breadcrumb.sp-menu-breadcrumb
          ul
            li
              a(@click.stop.prevent='clear_selected_ranking_type')
                span.sp-breadcrumb-icon
                  font-awesome-icon(:icon="['fas', 'home']")
                span {{$translate('ui.menu.rankings.header')}}

            li.is-active(v-for='label in selected_parent_labels')
              a
                span {{$translate(label)}}

        .is-size-5.ranking-title-industry(v-if='selected_ranking_type.category_total || selected_ranking_type.industry_type_id')
          misc-industry-type-icon(:industry_type='selected_ranking_type.industry_type_id' v-if='selected_ranking_type.industry_type_id')
          misc-industry-category-icon(small=true :category='selected_ranking_type.industry_category_id' v-else-if='selected_ranking_type.industry_category_id')
          font-awesome-icon(:icon="['fas', 'medal']" v-else)
          span.title-label {{$translate(label_for_type(selected_ranking_type))}}

      aside.sp-scrollbar.container-ranking-tycoons
        template(v-if='is_loading')
          .sp-menu-loading-container
            img.starpeace-logo

        template(v-else)
          menu-rankings-ranking-option(
            v-for='ranking in sorted_rankings'
            :client-state='client_state'
            :ajax-state='ajax_state'
            :ranking='ranking'
            :ranking-type='selected_ranking_type'
            :key="selected_ranking_type.id + '-' + ranking.rank"
            @toggle='select_tycoon'
          )

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

declare interface MainMenuData {
  ranking_nodes: Array<any>;
  rankings: any | null;
}

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true }
  },

  data (): MainMenuData {
    return {
      ranking_nodes: [],
      rankings: null
    };
  },

  computed: {
    is_ready (): boolean { return this.client_state.initialized && this.client_state.workflow_status === 'ready'; },
    is_visible (): boolean { return this.is_ready && (this.client_state?.menu?.is_visible('rankings') ?? false); },

    ranking_types () { return this.is_visible ? _.values(this.client_state?.core?.planet_library?.ranking_types_by_id) : []; },
    sorted_rankings () { return this.is_visible ? _.orderBy(this.rankings, ['rank'], ['asc']) : []; },

    is_loading () {
      if (!this.is_visible || !this.client_state.player.planet_id?.length || !this.selected_ranking_type_id?.length || !this.rankings) return false;
      return this.ajax_state?.request_mutex['planet_rankings']?.[`${this.client_state.player.planet_id}:${this.selected_ranking_type_id}`] ?? false;
    },

    selected_ranking_type_id () { return this.is_visible ? this.client_state?.interface?.selected_ranking_type_id : null; },
    selected_ranking_type () { return this.is_visible && this.selected_ranking_type_id?.length ? this.client_state?.core?.planet_library?.ranking_type_for_id(this.selected_ranking_type_id) : null; },

    selected_parent_labels () {
      if (!this.is_visible) return [];
      if (!this.selected_ranking_type.parent_id?.length) return [this.label_for_type(this.selected_ranking_type)];
      const parent_labels = [];
      const values = [this.selected_ranking_type.parent_id];
      while (values.length) {
        const type = this.client_state?.core?.planet_library?.ranking_type_for_id(values.shift());
        if (type) parent_labels.unshift(this.label_for_type(type));
        if (type?.parent_id?.length) values.push(type?.parent_id);
      }
      return parent_labels;
    }
  },

  mounted () {
    this.client_state.core.planet_cache.subscribe_rankings_listener(() => this.refresh_rankings());
  },

  watch: {
    ranking_types () {
      this.refresh_nodes();
    },
    selected_ranking_type_id () {
      this.client_state.interface.select_ranking_corporation_id(null);
      this.refresh_rankings();
    }
  },

  methods: {
    refresh_nodes () {
      this.ranking_nodes = _.map(_.values(this.client_state?.core?.planet_library?.ranking_type_roots()), this.type_to_node);
    },
    refresh_rankings () {
      this.rankings = this.selected_ranking_type_id?.length ? (this.client_state.core.planet_cache.rankings(this.selected_ranking_type_id) ?? []) : [];
    },

    select_ranking_type (ranking_type_id: string) {
      this.rankings = null;
      this.client_state.interface.toggle_ranking_corporation_id(null);
      this.client_state.interface.select_ranking_type_id(ranking_type_id);
    },
    clear_selected_ranking_type () {
      this.client_state.interface.toggle_ranking_corporation_id(null);
      this.client_state.interface.select_ranking_type_id(null);
    },
    select_tycoon (tycoon_id: string) {
      this.client_state.interface.toggle_ranking_corporation_id(tycoon_id);
    },

    root_for_node (type_id: string) {
      const values = [type_id];
      while (values.length) {
        const type = this.client_state?.core?.planet_library?.ranking_type_for_id(values.shift());
        if (!type?.parent_id?.length) return type;
        values.push(type?.parent_id);
      }
      return null;
    },

    type_to_node (type: any): any {
      return {
        id: type.id,
        label: this.label_for_type(type),
        category_total: type.category_total,
        industry_category_id: type.industry_category_id,
        industry_type_id: type.industry_type_id,
        expanded: false,
        children: _.map(this.client_state.core.planet_library.ranking_type_for_parent_id(type.id), this.type_to_node)
      };
    },

    label_for_type (type: any) {
      if (type.category_total) return 'ui.menu.rankings.label.total';
      if (type.label) return type.label;
      if (type.industry_type_id) return this.client_state.core.planet_library.type_for_id(type.industry_type_id)?.label;
      if (type.industry_category_id) return this.client_state.core.planet_library.category_for_id(type.industry_category_id)?.label;
      return type.id;
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

  .container-ranking-type
    grid-row: 2 / span 1
    overflow-y: scroll


.container-ranking-tycoons
  background-color: darken($sp-dark-bg, 10%)
  overflow-y: scroll

.ranking-title-industry
  align-items: center
  border-top: 1px solid darken($sp-primary, 15%)
  display: flex
  padding: .25rem .75rem

  .title-label
    margin-left: .4rem
    padding: .25rem 0

</style>
