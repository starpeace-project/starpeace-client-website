<template lang='pug'>
.research-container
  .tree-list-container.sp-scrollbar
    .status-title.sp-kv-key {{$translate('ui.menu.research.status.available')}}
    ul
      template(v-if="company_research.available.length")
        li(v-for="research in company_research.available")
          a(@click.stop.prevent="select_invention_id(research.id)") {{$translate(research.name)}}
      template(v-else)
        li {{$translate('ui.menu.research.none.label')}}

    .status-title.sp-kv-key {{$translate('ui.menu.research.status.in_progress')}}
    ul
      template(v-if="company_research.in_progress.length")
        li(v-for="research in company_research.in_progress")
          a(@click.stop.prevent="select_invention_id(research.id)") {{$translate(research.name)}}
      template(v-else)
        li {{$translate('ui.menu.research.none.label')}}

    .status-title.sp-kv-key {{$translate('ui.menu.research.status.completed')}}
    ul
      template(v-if="company_research.completed.length")
        li(v-for="research in company_research.completed")
          a(@click.stop.prevent="select_invention_id(research.id)") {{$translate(research.name)}}
      template(v-else)
        li {{$translate('ui.menu.research.none.label')}}

  .tree-container
    vue2viz-network.inverse-card(ref='tree_network' :options='tree_options' :nodes='tree_nodes' :edges='tree_edges' @select-node="select_tree_node" @deselect-node='deselect_tree_node')

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

const NODE_CONFIG = {
  available: {
    borderColor: '#083B2C',
    color: 'rgba(85,136,121,0.5)',
    hover: {
      borderColor: '#3C6F60',
      color: 'rgba(85,136,121,1)'
    },
    selected: {
      borderColor: '#56897A',
      color: 'rgba(85,136,121,1)'
    }
  },
  pending: {
    borderColor: '#12083B',
    color: 'rgba(94,84,135,0.5)',
    hover: {
      borderColor: '#12083B',
      color: 'rgba(94,84,135,1)'
    },
    selected: {
      borderColor: '#12083B',
      color: 'rgba(94,84,135,1)'
    }
  },
  completed: {
    borderColor: '#313B08',
    color: 'rgba(125,135,84,0.8)',
    hover: {
      borderColor: '#313B08',
      color: 'rgba(125,135,84,1)'
    },
    selected: {
      borderColor: '#313B08',
      color: 'rgba(125,135,84,1)'
    }
  }
};

const EDGE_CONFIG = {
  width: 4,
  borderColor: 'rgba(8,59,44,0.4)',
  hover: {
    borderColor: 'rgba(8,59,44,0.7)'
  },
  selected: {
    borderColor: 'rgba(8,59,44,1)'
  }
};


export default {
  props: {
    client_state: { type: ClientState, required: true },
    isVisible: Boolean
  },

  data () {
    return {
      inventions_for_company: this.client_state.inventions_for_company() ?? [],

      layout_locked: false,

      tree_nodes: [],
      tree_edges: [],
      tree_options: {
        interaction: {
          dragNodes: false,
          hover: true
        },

        layout: {
          randomSeed: 0
        },

        physics: {
          solver: 'repulsion'
        },

        nodes: {
          font: {
            color: '#DDDDDD'
          },
          margin: 10,
          shape: 'box'
        }
      }
    };
  },

  mounted () {
    this.client_state.corporation.subscribe_company_inventions_listener(() => this.refresh_tree());
    this.client_state.options.subscribe_options_listener(() => this.refresh_invention_data());
  },

  watch: {
    isVisible (new_value, old_value) {
      if (this.isVisible) {
        this.inventions_for_company = this.client_state.inventions_for_company();
        this.$refs.tree_network?.fit();
      }
    },

    company_id (new_value, old_value) {
      if (this.isVisible) {
        this.inventions_for_company = this.client_state.inventions_for_company();
        this.$refs.tree_network?.fit();
      }
    },

    invention_data (new_value, old_value) {
      this.refresh_invention_data();
    },

    selected_invention_id (new_value, old_value) {
      const invention_within_selection = _.find(this.invention_data, (invention) => invention.id === new_value);
      if (!invention_within_selection && new_value) {
        const invention_metadata = this.client_state.core.invention_library.metadata_for_id(new_value);
        if (invention_metadata) {
          this.client_state.interface.inventions_selected_category_id = invention_metadata.industry_category_id;
          this.client_state.interface.inventions_selected_industry_type_id = invention_metadata.industry_type_id;
        }
      }

      setTimeout(() => {
        if (this.selected_invention_id && this.$refs.tree_network) {
          this.$refs.tree_network?.selectNodes([this.selected_invention_id]);
        }
      }, 100);
    }
  },

  computed: {
    selected_category_id (): string | null { return this.client_state.interface?.inventions_selected_category_id; },
    selected_industry_type_id (): string | null { return this.client_state.interface?.inventions_selected_industry_type_id; },
    selected_invention_id (): string | null { return this.client_state.interface?.inventions_selected_invention_id; },

    invention_data () {
      const inventions: Record<string, any> = {};
      const to_search: Array<any> = [];
      for (const invention of this.inventions_for_company) {
        if (invention.industry_category_id === this.selected_category_id && (invention.industry_type_id || 'GENERAL') === this.selected_industry_type_id) {
          inventions[invention.id] = invention;
          to_search.push(invention.id);
        }
      }

      while (to_search.length) {
        const invention_id = to_search.pop()
        const invention_metadata = this.client_state.core.invention_library.metadata_for_id(invention_id);

        for (const depends_id of (invention_metadata?.depends_on || [])) {
          if (!inventions[depends_id]) {
            inventions[depends_id] = this.client_state.core.invention_library.metadata_for_id(depends_id);
            to_search.push(depends_id);
          }
        }
      }

      return _.values(inventions);
    },

    company_id (): string | null { return this.client_state.player.company_id; },
    company_inventions () { return this.isVisible && this.client_state.player.company_id ? this.client_state.corporation.inventions_metadata_by_company_id[this.client_state.player.company_id] : null; },

    company_research () {
      const research = {
        available: [],
        in_progress: null,
        pending: [],
        completed: []
      };

      for (const invention of this.invention_data) {
        if (this.company_inventions?.completedIds?.has(invention.id)) {
          research.completed.push({ id: invention.id, name: invention.name });
        }
        else if (this.company_inventions?.isQueued(invention.id)) {
          research.pending.push({ id: invention.id, name: invention.name });
        }
        else {
          research.available.push({ id: invention.id, name: invention.name });
        }
      }

      return {
        available: _.sortBy(research.available, (invention) => invention.text),
        in_progress: (research.in_progress ? [research.in_progress] : []).concat(research.pending),
        completed: _.sortBy(research.completed, (invention) => invention.text)
      };
    }
  },

  methods: {
    refresh_tree () {
      if (!this.isVisible) return;
      this.inventions_for_company = this.client_state.inventions_for_company();
      for (const node of this.tree_nodes) {
        node.color = this.color_for_node(node.id);
      }
      this.$refs.tree_network.fit();
    },

    refresh_invention_data () {
      if (!this.isVisible) return;

      const data = [];
      const links = [];
      for (const invention of this.invention_data) {
        data.push({
          id: invention.id,
          label: this.$translate(invention.name),
          color: this.color_for_node(invention.id)
        })

        if (invention.depends_on?.length) {
          for (let index = 0; index < invention.depends_on.length; index++) {
            const depends_on_id = invention.depends_on[index];
            links.push({
              id: `${depends_on_id}-${invention.id}`,
              from: depends_on_id,
              to: invention.id,
              arrows: {
                to: {
                  enabled: true,
                  scaleFactor: .5
                }
              },
              color: {
                color: EDGE_CONFIG.borderColor,
                hover: EDGE_CONFIG.hover.borderColor,
                highlight: EDGE_CONFIG.selected.borderColor
              },
              width: EDGE_CONFIG.width
            });
          }
        }
      }
      this.tree_nodes = data;
      this.tree_edges = links;

      setTimeout(() => {
        this.$refs.tree_network.fit()
        if (this.selected_invention_id) {
          this.$refs.tree_network.selectNodes([this.selected_invention_id]);
        }
      }, 100);
    },

    color_for_node (invention_id) {
      let item_styling = NODE_CONFIG.available;
      if (this.company_inventions?.isQueued(invention_id)) item_styling = NODE_CONFIG.pending;
      if (this.company_inventions?.completedIds?.has(invention_id)) item_styling = NODE_CONFIG.completed;

      return {
        background: item_styling.color,
        border: item_styling.borderColor,
        hover: {
          background: item_styling.hover.color,
          border: item_styling.hover.borderColor
        },
        highlight: {
          background: item_styling.selected.color,
          border: item_styling.selected.borderColor
        }
      };
    },

    select_tree_node (item) {
      this.select_invention_id(item.nodes?.length ? item.nodes[0] : null);
    },
    deselect_tree_node (item) {
      this.select_invention_id(null);
    },

    select_invention_id (invention_id: string) {
      this.client_state.interface.inventions_selected_invention_id = invention_id;
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.research-container
  position: relative
  grid-column: 2 / 3
  grid-row: 1 / 2

  .tree-list-container
    height: 100%
    left: 0
    overflow-y: scroll
    padding: 1rem .5rem 0
    position: absolute
    top: 0
    width: 20rem

    .status-title
      border-bottom: 1px solid $sp-primary
      margin-bottom: .25rem
      padding-bottom: .25rem

      &:not(:first-child)
        margin-top: 1.5rem

  .tree-container
    height: 100%
    padding: 0
    margin-left: 20rem
    width: calc(100% - 20rem)

    .inverse-card
      background-color: #000
      border: 0 !important
      height: 100% !important
      margin: 0
      padding: 0
      width: 100% !important

</style>
