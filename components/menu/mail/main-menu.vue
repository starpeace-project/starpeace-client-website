<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.mail.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('mail')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.p-0
    misc-card-loading(:visible='loading' within-absolute=true)
    misc-modal-loading(v-show='loading' within-absolute=true)

    menu-mail-contacts(
      :ajax_state='ajax_state'
      :client_state='client_state'
      :loading='loading'
    )
    menu-mail-messages(
      :ajax_state='ajax_state'
      :client_state='client_state'
      :loading='loading'
      @compose='compose_new'
      @delete='selected_delete'
      @reply='selected_reply'
      @forward='selected_forward'
    )

    template(v-if='is_compose_mode')
      menu-mail-message-compose(
        :ajax_state='ajax_state'
        :client_state='client_state'
        :loading='loading'
        @cancel='compose_cancel'
        @send='compose_send'
      )
    template(v-else-if='selected_mail')
      menu-mail-message-view(:ajax_state='ajax_state' :client_state='client_state')

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true },
  },

  data () {
    return {
      menu_visible: this.client_state?.menu?.is_visible('mail') ?? false,
      loading: false
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

    is_compose_mode () { return this.client_state.player.mail_compose_mode; },
    selected_mail () { return this.client_state.player.selected_mail_id ? this.client_state.player.mail_by_id[this.client_state.player.selected_mail_id] : null; }
  },

  methods: {
    async selected_delete () {
      if (!this.selected_mail || this.loading) return;
      this.loading = true;
      try {
        await this.$starpeaceClient.managers.mail_manager.delete(this.client_state.player.corporation_id, this.selected_mail.id);
      }
      catch (err) {
        this.client_state.add_error_message('Failure deleting mail, please try again', err);
      }
      finally {
        this.loading = false;
      }
    },

    embed_mail_details (mail) {
      const lines = [];
      lines[lines.length] = "";
      lines[lines.length] = "";
      lines[lines.length] = "----------";
      lines[lines.length] = `${this.$translate('ui.menu.mail.contacts.compose.from')}: ${mail.from_entity.name}`;
      lines[lines.length] = `${this.$translate('ui.menu.mail.contacts.compose.sent')}: ${mail.planet_sent_at.toFormat('MMM d, yyyy')} (${mail.sent_at.toFormat('yyyy-MM-dd HH:mm [UTC]')})`;
      lines[lines.length] = `${this.$translate('ui.menu.mail.contacts.compose.to')}: ${_.map(mail.to_entities, 'name').join('; ')}`;
      lines[lines.length] = `${this.$translate('ui.menu.mail.contacts.compose.subject')}: ${mail.subject}`;
      lines[lines.length] = "";
      lines[lines.length] = mail.body;
      return lines.join('\n');
    },


    selected_reply () {
      if (!this.selected_mail || this.loading) return;
      this.client_state.player.mail_compose_mode = true;
      this.client_state.player.mail_compose_to = this.selected_mail.from_entity.name;
      this.client_state.player.mail_compose_subject = `RE: ${this.selected_mail.subject}`;
      this.client_state.player.mail_compose_body = this.embed_mail_details(this.selected_mail);
    },

    selected_forward () {
      if (!this.selected_mail || this.loading) return;
      this.client_state.player.mail_compose_mode = true;
      this.client_state.player.mail_compose_to = '';
      this.client_state.player.mail_compose_subject = `FW: ${this.selected_mail.subject}`;
      this.client_state.player.mail_compose_body = this.embed_mail_details(this.selected_mail);
    },

    compose_new () {
      if (!this.has_corporation || this.loading) return;
      if (this.client_state.player.mail_compose_mode) {
        this.client_state.player.end_compose();
      }
      else {
        this.client_state.player.start_compose();
      }
    },

    compose_cancel () {
      if (this.loading) return;
      this.client_state.player.end_compose();
    },

    async compose_send () {
      if (this.loading) return;
      this.loading = true;
      try {
        await this.$starpeaceClient.managers.mail_manager.send_mail(this.client_state.player.corporation_id, this.client_state.player.mail_compose_to, this.client_state.player.mail_compose_subject, this.client_state.player.mail_compose_body);
        this.client_state.player.end_compose();
      }
      catch (err) {
        this.client_state.add_error_message('Failure sending mail, please try again', err);
      }
      finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-left / end-render
  grid-row: start-render / end-inspect
  position: relative

  > .card-content
    grid-template-columns: 25rem 30% auto

</style>
