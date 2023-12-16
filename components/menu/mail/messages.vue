<template lang='pug'>
.overall-container

  .level.is-mobile.sp-actions-container.is-top
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('compose')" :disabled='!can_compose' :class="{'is-active': compose_mode}") {{$translate('ui.menu.mail.contacts.action.new')}}
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('delete')" :disabled='!can_message_action') {{$translate('ui.menu.mail.contacts.action.delete')}}
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('reply')" :disabled='!can_message_action') {{$translate('ui.menu.mail.contacts.action.reply')}}
    .level-item.action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('forward')" :disabled='!can_message_action') {{$translate('ui.menu.mail.contacts.action.forward')}}

  aside.sp-scrollbar
    .mail-item(v-for='mail in mails' :class="{'selected':mail.id==selected_mail_id, 'unread':!mail.read}")
      a(@click.stop.prevent="select_mail(mail.id)")
        span.mail-info
          span {{mail.from_entity.name}}
          span.mail-subject {{mail.subject}}
        span.mail-date {{mail.planet_sent_at.toFormat('D')}}

  .status-bar

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

declare interface MessagesData {
  menu_visible: boolean;
  mode: string;
  mark_read_mail_id: string | null;
  mark_read_callback: any | null;
}


export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true },

    loading: { type: Boolean, required: true }
  },

  data (): MessagesData {
    return {
      menu_visible: this.client_state.menu?.is_visible('mail') ?? false,

      mode: 'CONTACTS',

      mark_read_mail_id: null,
      mark_read_callback: null
    };
  },

  mounted () {
    this.client_state?.menu?.subscribe_menu_listener(() => {
      this.menu_visible = this.client_state?.menu?.is_visible('mail') ?? false;
    });
  },

  computed: {
    is_ready () { return this.client_state.workflow_status === 'ready'; },
    has_corporation () { return this.is_ready && this.client_state.is_tycoon() && this.client_state.player.corporation_id?.length > 0; },

    selected_mail_id () { return this.client_state.player.selected_mail_id; },
    selected_mail () { return this.selected_mail_id ? this.client_state.player.mail_by_id[this.selected_mail_id] : null; },

    compose_mode () { return this.client_state.player.mail_compose_mode; },

    can_compose (): boolean { return this.has_corporation && !this.loading; },
    can_message_action (): boolean { return this.has_corporation && this.selected_mail_id?.length > 0 && !this.compose_mode && !this.loading; },
    actions_disabled (): boolean { return !this.is_ready && this.has_corporation; },

    mails () { return _.orderBy(_.values(this.client_state.player.mail_by_id), ['sent_at'], ['desc']); }
  },

  methods: {
    async mark_read (mail_id: string) {
      try {
        await this.$starpeaceClient.managers.mail_manager.mark_read(this.client_state.player.corporation_id, mail_id);
      }
      catch (err) {
        this.client_state.add_error_message('Failure marking mail read', err);
      }
      finally {
        this.mark_read_mail_id = null;
        this.mark_read_callback = null;
      }
    },

    select_mail (mail_id: string) {
      if (this.loading) return;

      if (!this.client_state.player.mail_compose_mode && this.client_state.player.selected_mail_id === mail_id) {
        this.client_state.player.selected_mail_id = null;
        return;
      }

      if (this.client_state.player.mail_compose_mode) {
        this.client_state.player.end_compose();
      }

      if (this.mark_read_callback && this.mark_read_mail_id !== mail_id) {
        this.mark_read_mail_id = null;
        clearTimeout(this.mark_read_callback);
      }

      if (this.client_state.player.mail_by_id[mail_id] && !this.client_state.player.mail_by_id[mail_id].read) {
        this.mark_read_mail_id = mail_id;
        this.mark_read_callback = setTimeout(() => this.mark_read(mail_id), 500);
      }

      this.client_state.player.selected_mail_id = mail_id;
    }
  }
}
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
