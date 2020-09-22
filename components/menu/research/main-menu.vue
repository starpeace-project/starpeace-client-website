<template lang='pug'>

#research-details-container.card.is-starpeace.has-header
  .card-header
    .card-header-title {{translate('ui.menu.research.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('research')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.is-paddingless
    menu-research-menu(:managers='managers' :client_state='client_state')
    menu-research-tree(:managers='managers' :client_state='client_state')
    menu-research-details(:managers='managers' :ajax_state='ajax_state' :client_state='client_state')

  #no-company-modal.modal-background(v-show='has_no_company')
    .content
      span {{translate('ui.menu.construction.company_required.label')}}
      a(@click.stop.prevent='toggle_form_company_menu') {{translate('ui.menu.construction.company_required.action')}}

</template>

<script lang='coffee'>
import MenuResearchMenu from '~/components/menu/research/menu.vue'
import MenuResearchDetails from '~/components/menu/research/details.vue'
import MenuResearchTree from '~/components/menu/research/tree.vue'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  components: {
    MenuResearchDetails
    MenuResearchMenu
    MenuResearchTree
  }

  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  computed:
    has_no_company: ->
      return false unless @client_state?.workflow_status == 'ready'
      @client_state.is_tycoon() && !@client_state.player.company_id?

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    toggle_form_company_menu: () -> @client_state.menu.toggle_menu('company_form')

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#research-details-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 5
  margin: 0
  overflow: hidden
  z-index: 1150

  .card-header
    height: 3.4rem

  .card-header-title
    font-size: 1.15rem
    letter-spacing: .2rem
    padding-top: .65rem

  .card-content
    height: calc(100% - 3.4rem)
    padding: 0
    display: grid
    grid-template-columns: 25rem auto 25rem
    grid-template-rows: 100%

#no-company-modal
  align-items: center
  display: flex
  justify-content: center
  padding: 1rem
  text-align: center
  top: 3.4rem
  z-index: 1000

  .content
    color: $sp-primary
    font-size: 1.5rem
    font-style: italic

  a
    font-weight: bold
    color: $sp-primary
    margin-left: .4rem

    &:not([disabled])
      &:hover,
      &.is-hover
        color: $sp-light

      &:active,
      &.is-active
        color: #fff

</style>
