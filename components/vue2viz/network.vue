<template>
  <div ref="root"/>
</template>

<script lang="ts">
import { markRaw } from 'vue';
import { Network } from 'vis-network';

export default {
  props: {
    options: { type: Object, required: true },
    nodes: { type: Array, required: true },
    edges: { type: Array, required: true }
  },

  data () {
    return {
      network: null
    };
  },

  computed: {
    networkNodedIds () { return new Set<string>(this.nodes.map(n => n.id)); }
  },

  mounted () {
    const el : HTMLElement | any = this.$refs.root;
    this.network = markRaw(new Network(el, {
      nodes: this.nodes,
      edges: this.edges
    }, this.options));

    this.network.on('selectNode', (event) => this.$emit('select-node', event));
    this.network.on('deselectNode', (event) => this.$emit('deselect-node', event));
  },

  beforeUnmount () {
    this.network?.destroy();
  },

  watch: {
    nodes (newValue, oldValue) {
      this.network.setData({
        nodes: this.nodes ?? [],
        edges: this.edges ?? []
      });
      this.network.fit();
      this.network.redraw();
    },
    options (newValue, oldValue) {
      this.network.setOptions(this.options);
      this.network.redraw();
    }
  },

  methods: {
    selectNodes (nodeIds) {
      this.network.selectNodes(nodeIds.filter(id => this.networkNodedIds.has(id)));
    },

    fit () {
      this.network.fit();
    }
  }
}
</script>