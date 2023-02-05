<template lang='pug'>
#application-container(:class='application_css_class', v-cloak=true)
  page-layout-header(:managers='managers', :client_state='client_state')
  misc-card-loading(:client_state='client_state' within-grid=true)
  misc-modal-loading(:client_state='client_state' within-grid=true)
  misc-card-webgl-warning(:client_state='client_state')
  workflow(:client='client', :client_state='client_state')
  page-layout-render-container(:client_state='client_state')
</template>

<script lang='coffee'>
export default
  props:
    client: Object

  mounted: ->
    @client.options?.subscribe_options_listener =>
      @show_header = @client.options.option('general.show_header')

  data: ->
    client_state: @client?.client_state
    options: @client?.options

    show_header: @client?.options?.option('general.show_header')

  computed:
    application_css_class: -> if @show_header then [] else ['no-header']

    managers: -> @client?.managers
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'

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
