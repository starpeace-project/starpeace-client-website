<template lang='pug'>
span.company-seal-icon-wrapper(:class="with_min_size ? 'is-min-sized' : ''")
  template(v-if="seal_id == 'DIS'")
    font-awesome-icon(:icon="['fab', 'bimobject']", flip='horizontal')
  template(v-else-if="seal_id == 'MAGNA'")
    font-awesome-icon(:icon="['fab', 'megaport']")
  template(v-else-if="seal_id == 'MKO'")
    font-awesome-icon(:icon="['fab', 'monero']")
  template(v-else-if="seal_id == 'MOAB'")
    font-awesome-icon(:icon="['fab', 'mizuni']")
  template(v-else-if="seal_id == 'PGI'")
    font-awesome-icon(:icon="['fas', 'parking']")
  template(v-else-if="true")
    font-awesome-icon(:icon="['far', 'circle']")
</template>

<script lang='ts'>
export default {
  name: 'company-seal-icon',
  props: {
    seal_id: { type: String, required: true },

    with_min_size: { type: Boolean, required: false }
  }
}
</script>

<style lang='sass' scoped>
.company-seal-icon-wrapper
  &.is-min-sized
    display: inline-block
    min-width: 1.25rem
    text-align: center

</style>
