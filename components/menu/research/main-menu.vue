<template lang='pug'>

.card.has-header.is-starpeace.sp-menu
  .card-header
    .card-header-title {{translate('ui.menu.research.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('research')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.is-paddingless
    menu-research-menu(:managers='managers' :client_state='client_state')
    menu-research-tree(:managers='managers' :client_state='client_state')
    menu-research-details(:managers='managers' :ajax_state='ajax_state' :client_state='client_state')

  .sp-menu-modal(v-show='has_no_company')
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
@import '~assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-left / end-right
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: 25rem auto 25rem

</style>
