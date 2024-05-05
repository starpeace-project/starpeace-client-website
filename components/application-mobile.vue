<template lang='pug'>
#application-container(:class='application_css_class' v-cloak=true)
  page-layout-header(:client-state='client_state')
  misc-card-loading(:client_state='client_state' within-grid)
  misc-modal-loading(:client_state='client_state' within-grid)
  misc-card-webgl-warning(:client_state='client_state')
  workflow(:client_state='client_state')
  page-layout-render-container(:client_state='client_state')
</template>

<script lang='ts'>
export default {
  mounted () {
    this.$starpeaceClient.options?.subscribe_options_listener(() => {
      this.show_header = this.$starpeaceClient.options.option('general.show_header');
    });
  },

  data () {
    return {
      client_state: this.$starpeaceClient?.client_state,
      options: this.$starpeaceClient?.options,

      show_header: this.$starpeaceClient?.options?.option('general.show_header')
    };
  },

  computed: {
    application_css_class () { return this.show_header ? [] : ['no-header']; }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/mixins'

#application-container
  display: grid
  grid-template-columns: 0 auto 0
  grid-template-rows: 4rem auto 3rem 5rem 10.5rem
  grid-row-gap: 0
  height: 100vh
  position: relative

  +mobile
    grid-template-rows: calc(11vw + 1.5rem) auto 3rem 5rem 10.5rem

    #common-header
      display: inline-block
      width: 100%

  &.no-header
    +mobile
      grid-template-rows: calc(1rem) auto 3rem 5rem 10.5rem

</style>
