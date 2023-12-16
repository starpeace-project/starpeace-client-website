<template lang='pug'>
.sp-slider
  input(
    type='range'
    :list='markerValues.length ? listId : undefined'
    :min='min'
    :max='max'
    :step='step'
    :disabled='!!disabled'
    v-model='basisPoints'
    @change.stop="$emit('change', basisPoints / 100)"
  )

  template(v-if='markerValues.length')
    datalist(:id='listId')
      option(v-for='value in markerValues' :value='value')
</template>

<script lang='ts'>
import Utils from '~/plugins/starpeace-client/utils/utils';

export default {
  props: {
    markers: { type: Array<number>, required: false },
    disableMarkers: { type: Boolean, required: false },

    min: { type: Number, required: false, default: 0 },
    max: { type: Number, required: true },
    step: { type: String, required: false, default: 'any' },

    percent: { type: Number, required: true },

    disabled: { type: Boolean, required: false },
  },

  data () {
    return {
      listId: Utils.uuid()
    };
  },

  computed: {
    markerValues (): Array<number> {
      if (this.markers?.length) {
        return this.markers;
      }
      return this.disableMarkers ? [] : [this.min, this.max];
    },

    basisPoints : {
      get (): number {
        return this.percent * 100;
      },
      set (ratio: number): void {
        this.$emit('update', ratio / 100);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'
</style>
