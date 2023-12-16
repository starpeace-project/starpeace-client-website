<template>
  <div ref="root"/>
</template>

<script lang="ts">
import { markRaw } from 'vue';
import { Network } from 'vis-network';

declare interface NetworkData {
  network: Network | undefined;
}

export default {
  props: {
    options: { type: Object, required: true },
    nodes: { type: Array<any>, required: true },
    edges: { type: Array<any>, required: true },
    selectedNodes: { type: Array<string>, required: false }
  },

  data (): NetworkData {
    return {
      network: undefined
    };
  },

  computed: {
    networkNodedIds (): Set<string> {
      return new Set<string>(this.nodes.map((n: any) => n.id));
    },

    selectableNodeIds (): Array<string> {
      return (this.selectedNodes ?? []).filter((id: string) => this.networkNodedIds.has(id));
    }
  },

  mounted () {
    const el : HTMLElement | any = this.$refs.root;
    this.network = markRaw(new Network(el, {
      nodes: this.nodes,
      edges: this.edges
    }, this.options));
    this.network.selectNodes(this.selectableNodeIds);

    this.network.on('selectNode', (event) => this.$emit('select-node', event));
    this.network.on('deselectNode', (event) => this.$emit('deselect-node', event));
  },

  beforeUnmount () {
    this.network?.destroy();
  },

  watch: {
    nodes: {
      deep: true,
      handler (newValue, oldValue) {
        if (this.network) {
          this.network.setData({
            nodes: this.nodes,
            edges: this.edges
          });
          this.network.selectNodes(this.selectableNodeIds);
          this.network.fit();
          this.network.redraw();
        }
      }
    },
    options (newValue, oldValue) {
      if (this.network) {
        this.network.setOptions(this.options);
        this.network.fit();
        this.network.redraw();
      }
    }
  },

  methods: {
    selectNodes (nodeIds: Array<string>) {
      this.network?.selectNodes(nodeIds.filter(id => this.networkNodedIds.has(id)));
    },

    fit () {
      this.network?.fit();
    }
  }
}
</script>