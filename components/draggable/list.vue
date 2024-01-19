<template lang='pug'>
div
  div.sortable-list(ref='root')
    template(v-for='item in modelValue' :key='item.id')
      slot(name='item' :item='item')
</template>

<script lang='ts'>
import _ from 'lodash';

import { type Draggable, Sortable, type SortableStartEvent, type SortableSortedEvent, type SortableStopEvent } from '@shopify/draggable';

export default {
  name: 'DraggableList',
  props: {
    modelValue: { type: Array, required: true }
  },

  data () {
    return {
      startIndex: -1
    };
  },

  mounted () {
    if (this.$refs.root) {
      this.instance = new Sortable(this.$refs.root, {
        draggable: '.draggable-item',
        distance: 3,
        exclude: {
          plugins: [Draggable.Plugins.Mirror],
          sensors: []
        }
      });

      this.instance.on('sortable:start', (event: SortableStartEvent) => {
        const index: number = this.indexWithAll(event.startIndex);
        if (index < 0 || index >= this.modelValue.length || this.modelValue[index].fixed) {
          event.cancel();
          return false;
        }

        this.startIndex = this.indexWithAll(event.startIndex);
        this.$emit('start', {
          startIndex: this.startIndex
        });
      });
      this.instance.on('sortable:sorted', (event: SortableSortedEvent) => {
        this.$emit('change', {
          oldIndex: this.startIndex,
          newIndex: this.indexWithAll(event.newIndex)
        });
      });
      this.instance.on('sortable:stop', (rawEvent: SortableStopEvent) => {
        const event = {
          oldIndex: this.startIndex,
          newIndex: this.indexWithAll(rawEvent.newIndex)
        };
        this.$emit('end', event);
        if (event.oldIndex !== event.newIndex) {
          this.$emit('update', event);
        }
      });
    }
  },

  methods: {
    domChildren (): Array<HTMLElement> {
      return this.$refs.root?.children ? [...this.$refs.root.children].filter(e => !e.classList.contains('draggable--original') && !!e.getAttribute('data-id')) : [];
    },
    domIds (): Array<string> {
      return this.domChildren().map(e => e.getAttribute('data-id')) as Array<string>;
    },
    draggableDomIds (): Array<string> {
      return this.domChildren().filter(e => e.classList.contains('draggable-item')).map(e => e.getAttribute('data-id')) as Array<string>;
    },

    indexWithAll (indexDraggable: number): number {
      const draggableDomIds: Array<string> = this.draggableDomIds();
      const id: string | undefined = indexDraggable < 0 || indexDraggable >= draggableDomIds.length ? undefined : draggableDomIds[indexDraggable];
      return id ? this.domIds().indexOf(id) : -1;
    }
  }
}
</script>

<style lang='sass' scoped>

</style>
