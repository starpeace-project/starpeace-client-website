<template lang='pug'>
.research-container.is-flex.is-flex.direction-row

  menu-research-company(
    :client-state='clientState'
    :connected-invention-definitions='connectedInventionDefinitions'
  )

  .tree-container
    vue2viz-network.inverse-card(
      ref='tree_network'
      :options='treeOptions'
      :nodes='inventionTree.nodes'
      :edges='inventionTree.edges'
      :selected-nodes='selectedNodes'
      @select-node="selectTreeNode"
      @deselect-node='deselectTreeNode'
    )

</template>

<script lang='ts'>
import _ from 'lodash';
import { InventionDefinition } from '@starpeace/starpeace-assets-types';

import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions';
import ClientState from '~/plugins/starpeace-client/state/client-state';

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
    clientState: { type: ClientState, required: true },
    connectedInventionDefinitions: { type: Array<InventionDefinition>, required: true },
    companyInventions: { type: CompanyInventions, required: false }
  },

  computed: {
    treeOptions (): any {
      return {
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
      };
    },
    selectedNodes () {
      return !!this.selectedInventionId ? [this.selectedInventionId] : [];
    },

    selectedInventionId (): string | undefined {
      return this.clientState.interface?.inventions_selected_invention_id ?? undefined;
    },

    inventionTree (): any {
      const nodes = [];
      const edges = [];
      for (const invention of this.connectedInventionDefinitions) {
        nodes.push({
          id: invention.id,
          label: this.$translate(invention.name),
          color: this.colorForInvention(invention.id)
        })

        if (invention.dependsOnIds?.length) {
          for (const dependencyId of invention.dependsOnIds) {
            edges.push({
              id: `${dependencyId}-${invention.id}`,
              from: dependencyId,
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
      return {
        nodes,
        edges
      };
    }
  },

  mounted () {
    this.clientState.corporation.subscribe_company_inventions_listener(() => this.refreshNetwork());
    this.clientState.options.subscribe_options_listener(() => this.refreshNetwork());
  },

  watch: {
    selectedInventionId: {
      immediate: true,
      handler () {
        const invention_within_selection = this.connectedInventionDefinitions.find((invention) => invention.id === this.selectedInventionId);
        if (!invention_within_selection && this.selectedInventionId) {
          const invention_metadata = this.clientState.core.invention_library.metadata_for_id(this.selectedInventionId);
          if (invention_metadata) {
            this.clientState.interface.inventions_selected_category_id = invention_metadata.industryCategoryId;
            this.clientState.interface.inventions_selected_industry_type_id = invention_metadata.industryTypeId;
          }
        }
        this.refreshNetwork();
      }
    }
  },

  methods: {
    refreshNetwork (): void {
      setTimeout(() => {
        if (this.$refs?.tree_network) {
          this.$refs.tree_network.fit()
          if (this.selectedInventionId) {
            this.$refs.tree_network.selectNodes([this.selectedInventionId]);
          }
        }
      }, 100);
    },

    colorForInvention (inventionId: string) {
      let styling = NODE_CONFIG.available;
      if (this.companyInventions?.isQueued(inventionId)) {
        styling = NODE_CONFIG.pending;
      }
      if (this.companyInventions?.completedIds?.has(inventionId)) {
        styling = NODE_CONFIG.completed;
      }

      return {
        background: styling.color,
        border: styling.borderColor,
        hover: {
          background: styling.hover.color,
          border: styling.hover.borderColor
        },
        highlight: {
          background: styling.selected.color,
          border: styling.selected.borderColor
        }
      };
    },

    selectTreeNode (item: any) {
      this.clientState.interface.inventions_selected_invention_id = item.nodes?.length ? item.nodes[0] : null;
    },
    deselectTreeNode (item: any) {
      this.clientState.interface.inventions_selected_invention_id = item.nodes?.length ? item.nodes[0] : null;
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

  .tree-container
    width: 100%

    .inverse-card
      background-color: #000
      border: 0 !important
      height: 100% !important
      margin: 0
      padding: 0
      width: 100% !important

</style>
