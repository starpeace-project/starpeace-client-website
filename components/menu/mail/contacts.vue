<template lang='pug'>
.overall-container

  .tabs.is-centered.is-toggle.is-fullwidth.sp-tabs
    ul
      li(:class="{'is-active':mode=='CONTACTS'}")
        a(:disabled='loading' @click.stop.prevent="mode='CONTACTS'") Contacts
      li(:class="{'is-active':mode=='ALLIES'}")
        a(:disabled='loading' @click.stop.prevent="mode='ALLIES'") Allies
      li(:class="{'is-active':mode=='BLOCKED'}")
        a(:disabled='loading' @click.stop.prevent="mode='BLOCKED'") Blocked

  aside.sp-scrollbar

  .level.is-mobile.sp-actions-container.is-bottom
    .level-item.action-column
      a.button.is-small.is-fullwidth.is-starpeace(disabled='disabled') {{translate('ui.menu.mail.contacts.action.organize')}}
    .level-item.action-column
      a.button.is-small.is-fullwidth.is-starpeace(@click.stop.prevent='show_add_contact' :disabled='actions_disabled') {{translate('ui.menu.mail.contacts.action.add')}}

</template>

<script lang='coffee'>

export default
  props:
    managers: Object
    ajax_state: Object
    client_state: Object

    loading: Boolean

  data: ->
    menu_visible: @client_state?.menu?.is_visible('mail')

    mode: 'CONTACTS'

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @menu_visible = @client_state?.menu?.is_visible('mail')

  computed:
    is_ready: -> @client_state.workflow_status == 'ready'
    has_corporation: -> if @is_ready then @client_state.is_tycoon() && @client_state.player.corporation_id?.length else false

    actions_disabled: -> !(@is_ready && @has_corporation && !@loading)

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    show_add_contact: () ->
      console.log 'show add contact'

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'
@import '~assets/stylesheets/starpeace-menus'

.overall-container
  position: relative

  > .tabs
    height: 4rem
    margin: 0
    padding-left: .5rem
    padding-right: 1.75rem

  > aside
    background-color: darken($sp-dark-bg, 10%) //#000D07
    height: calc(100% - 4rem - 3rem - .5rem)
    overflow-y: scroll

  > .sp-actions-container
    padding-right: 1.75rem

</style>
