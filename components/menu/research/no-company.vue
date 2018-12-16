<template lang='haml'>
#research-no-company-container{'v-if':'is_visible'}
  .modal-background
  .card
    .card-content
      .content
        Research is available after forming a company.
</template>

<script lang='coffee'>
export default
  props:
    client_state: Object

  computed:
    is_visible: ->
      return false unless @client_state?.workflow_status == 'ready'
      @client_state.identity.identity.is_tycoon() && !@client_state.player.company_id?

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#research-no-company-container
  display: flex
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 5
  margin: 0
  position: relative
  overflow: hidden
  z-index: 1500

  .modal-background
    background-color: #000
    height: 100%
    opacity: .7
    position: absolute
    width: 100%
    z-index: 1495

  > .card
    background-color: $sp-dark-bg
    margin: auto
    z-index: 1500

    .content
      color: $sp-primary
      font-size: 1.5rem
      font-style: italic
      font-weight: bold

</style>
