<template lang='pug'>
.overall-container

  .level.is-mobile.sp-actions-container.is-top
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('compose')" :disabled='!can_compose' :class="{'is-active': compose_mode}") {{translate('ui.menu.mail.contacts.action.new')}}
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('delete')" :disabled='!can_message_action') {{translate('ui.menu.mail.contacts.action.delete')}}
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('reply')" :disabled='!can_message_action') {{translate('ui.menu.mail.contacts.action.reply')}}
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('forward')" :disabled='!can_message_action') {{translate('ui.menu.mail.contacts.action.forward')}}

  aside.sp-scrollbar
    .mail-item(v-for='mail in mails' :class="{'selected':mail.id==selected_mail_id, 'unread':!mail.read}")
      a(@click.stop.prevent="select_mail(mail.id)")
        span.mail-info
          span {{mail.from_entity.name}}
          span.mail-subject {{mail.subject}}
        span.mail-date {{mail.planet_sent_at.toFormat('D')}}

  .status-bar

</template>

<script lang='coffee'>
import _ from 'lodash';

export default
  props:
    managers: Object
    ajax_state: Object
    client_state: Object

    loading: Boolean

  data: ->
    menu_visible: @client_state?.menu?.is_visible('mail')

    mode: 'CONTACTS'

    mark_read_mail_id: null
    mark_read_callback: null

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @menu_visible = @client_state?.menu?.is_visible('mail')

  computed:
    is_ready: -> @client_state.workflow_status == 'ready'
    has_corporation: -> if @is_ready then @client_state.is_tycoon() && @client_state.player.corporation_id?.length else false

    selected_mail_id: -> @client_state.player.selected_mail_id
    selected_mail: -> if @selected_mail_id? then @client_state.player.mail_by_id[@selected_mail_id] else null

    compose_mode: -> @client_state.player.mail_compose_mode

    can_compose: -> @has_corporation && !@loading
    can_message_action: -> @has_corporation && @selected_mail_id?.length && !@compose_mode && !@loading
    actions_disabled: -> !@is_ready && @has_corporation

    mails: -> _.orderBy(_.values(@client_state.player.mail_by_id), ['sent_at'], ['desc'])

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    mark_read: (mail_id) ->
      @managers.mail_manager.mark_read(@client_state.player.corporation_id, mail_id)
        .then =>
          @mark_read_mail_id = null
          @mark_read_callback = null
        .catch (err) =>
          @client_state.add_error_message('Failure marking mail read', err)
          @mark_read_mail_id = null
          @mark_read_callback = null

    select_mail: (mail_id) ->
      return if @loading

      if !@client_state.player.mail_compose_mode && @client_state.player.selected_mail_id == mail_id
        @client_state.player.selected_mail_id = null
        return

      if @client_state.player.mail_compose_mode
        @client_state.player.end_compose()

      if @mark_read_callback? && @mark_read_mail_id != mail_id
        @mark_read_mail_id = null
        clearTimeout(@mark_read_callback)

      if @client_state.player.mail_by_id[mail_id]? && !@client_state.player.mail_by_id[mail_id].read
        @mark_read_mail_id = mail_id
        @mark_read_callback = setTimeout((=> @mark_read(mail_id)), 500)

      @client_state.player.selected_mail_id = mail_id

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-menus'

.overall-container
  position: relative

  > .sp-actions-container
    margin: 0
    height: 4rem
    padding-right: 1.75rem

    .button
      letter-spacing: .1rem
      text-transform: uppercase

  > aside
    background-color: darken($sp-dark-bg, 10%)
    height: calc(100% - 4rem - 3rem - .5rem)
    overflow-y: scroll

  > .status-bar
    bottom: .5rem
    height: 1.5rem
    padding: .5rem
    position: absolute
    width: 100%

.mail-item
  background-color: darken($sp-primary-bg, 15%)

  &:not(:last-child)
    margin-bottom: 1px

  &.unread
    background-color: darken($sp-primary-bg, 7.5%)

    > a
      font-weight: bold

  &.selected
    background-color: darken($sp-primary-bg, 2.5%)

    > a
      color: lighten($sp-primary, 20%) !important

  > a
    display: flex
    flex-direction: row
    font-weight: normal
    padding: .5rem

  .mail-info
    display: flex
    flex-direction: column
    flex-grow: 1

    .mail-subject
      font-size: 1.25rem

  .mail-date
    display: inline-flex
    align-items: center

</style>
