<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(oncontextmenu='return false')
  .card-header
    .card-header-title {{translate('ui.menu.mail.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('mail')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.is-paddingless.sp-menu-background
    loading-card(:managers='managers' :visible='loading' within-absolute=true)
    loading-modal(v-show='loading' within-absolute=true)

    contacts(
      :managers='managers'
      :ajax_state='ajax_state'
      :client_state='client_state'
      :loading='loading'
    )
    messages(
      :managers='managers'
      :ajax_state='ajax_state'
      :client_state='client_state'
      :loading='loading'
      @compose='compose_new'
      @delete='selected_delete'
      @reply='selected_reply'
      @forward='selected_forward'
    )

    template(v-if='is_compose_mode')
      message-compose(
        :managers='managers'
        :ajax_state='ajax_state'
        :client_state='client_state'
        :loading='loading'
        @cancel='compose_cancel'
        @send='compose_send'
      )
    template(v-else-if='selected_mail')
      message-view(:managers='managers' :ajax_state='ajax_state' :client_state='client_state')

</template>

<script lang='coffee'>
import Contacts from '~/components/menu/mail/contacts.vue'
import Messages from '~/components/menu/mail/messages.vue'
import MessageCompose from '~/components/menu/mail/message-compose.vue'
import MessageView from '~/components/menu/mail/message-view.vue'

import LoadingCard from '~/components/misc/card-loading.vue'
import LoadingModal from '~/components/misc/modal-loading.vue'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  components: {
    Contacts
    Messages
    MessageCompose
    MessageView
    LoadingCard
    LoadingModal
  }

  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  data: ->
    menu_visible: @client_state?.menu?.is_visible('mail')
    loading: false

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @menu_visible = @client_state?.menu?.is_visible('mail')

  computed:
    is_ready: -> @client_state.workflow_status == 'ready'
    has_corporation: -> if @is_ready then @client_state.is_tycoon() && @client_state.player.corporation_id?.length else false

    is_compose_mode: -> @client_state.player.mail_compose_mode
    selected_mail: -> if @client_state.player.selected_mail_id? then @client_state.player.mail_by_id[@client_state.player.selected_mail_id] else null

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    selected_delete: () ->
      return unless @selected_mail? && !@loading
      @loading = true
      @managers.mail_manager.delete(@client_state.player.corporation_id, @selected_mail.id)
        .then =>
          @loading = false
        .catch (err) =>
          @client_state.add_error_message('Failure deleting mail, please try again', err)
          @loading = false

    embed_mail_details: (mail) ->
      lines = []
      lines[lines.length] = ""
      lines[lines.length] = ""
      lines[lines.length] = "----------"
      lines[lines.length] = "#{@translate('ui.menu.mail.contacts.compose.from')}: #{mail.from_entity.name}"
      lines[lines.length] = "#{@translate('ui.menu.mail.contacts.compose.sent')}: #{mail.planet_sent_at.format('MMM D, YYYY')} (#{mail.sent_at.format('YYYY-MM-DD HH:mm [UTC]')})"
      lines[lines.length] = "#{@translate('ui.menu.mail.contacts.compose.to')}: #{_.map(mail.to_entities, 'name').join('; ')}"
      lines[lines.length] = "#{@translate('ui.menu.mail.contacts.compose.subject')}: #{mail.subject}"
      lines[lines.length] = ""
      lines[lines.length] = mail.body
      lines.join('\n')


    selected_reply: () ->
      return unless @selected_mail? && !@loading
      @client_state.player.mail_compose_mode = true
      @client_state.player.mail_compose_to = @selected_mail.from_entity.name
      @client_state.player.mail_compose_subject = "RE: #{@selected_mail.subject}"
      @client_state.player.mail_compose_body = @embed_mail_details(@selected_mail)

    selected_forward: () ->
      return unless @selected_mail? && !@loading
      @client_state.player.mail_compose_mode = true
      @client_state.player.mail_compose_to = ''
      @client_state.player.mail_compose_subject = "FW: #{@selected_mail.subject}"
      @client_state.player.mail_compose_body = @embed_mail_details(@selected_mail)

    compose_new: () ->
      return unless @has_corporation && !@loading
      if @client_state.player.mail_compose_mode
        @client_state.player.end_compose()
      else
        @client_state.player.start_compose()

    compose_cancel: () ->
      return if @loading
      @client_state.player.end_compose()

    compose_send: () ->
      return if @loading
      @loading = true
      @managers.mail_manager.send_mail(@client_state.player.corporation_id, @client_state.player.mail_compose_to, @client_state.player.mail_compose_subject, @client_state.player.mail_compose_body)
        .then =>
          @client_state.player.end_compose()
          @loading = false
        .catch (err) =>
          @client_state.add_error_message('Failure sending mail, please try again', err)
          @loading = false

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-left / end-render
  grid-row: start-render / end-inspect
  position: relative

  > .card-content
    grid-template-columns: 25rem 30% auto

</style>
