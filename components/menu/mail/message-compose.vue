<template lang='pug'>
.overall-container
  .message-header-info
    .send-details-column
      .compose-metadata-row
        span {{$translate('ui.menu.mail.contacts.compose.to')}}
        input.input(type='text' v-model='mail_to' :disabled='loading')

      .compose-metadata-row
        span {{$translate('ui.menu.mail.contacts.compose.subject')}}
        input.input(type='text' v-model='mail_subject' :disabled='loading')

    .send-cancel-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('cancel')" :disabled='loading') {{$translate('ui.menu.mail.contacts.action.cancel')}}

    .send-action-column
      button.button.is-fullwidth.is-starpeace(@click.stop.prevent="$emit('send')" :disabled='!can_send') {{$translate('ui.menu.mail.contacts.action.send')}}

  textarea.mail-body-input.sp-scrollbar(ref='mailBody' v-model='mail_body' :disabled='loading')

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true },

    loading: { type: Boolean, required: true }
  },

  computed: {
    compose_mode (): boolean { return this.client_state.player.mail_compose_mode; },

    mail_to: {
      get (): string { return this.client_state.player.mail_compose_to; },
      set (new_value: string) { this.client_state.player.mail_compose_to = new_value; }
    },
    mail_subject: {
      get (): string { return this.client_state.player.mail_compose_subject; },
      set (new_value: string) { this.client_state.player.mail_compose_subject = new_value; }
    },
    mail_body: {
      get (): string { return this.client_state.player.mail_compose_body; },
      set (new_value: string) { this.client_state.player.mail_compose_body = new_value; }
    },

    can_send (): boolean { return this.compose_mode && !this.loading && _.trim(this.mail_to).length > 0 && _.trim(this.mail_subject).length > 0 && _.trim(this.mail_body).length > 0; }
  },

  watch: {
    compose_mode: {
      immediate: true,
      handler () {
        if (this.compose_mode) {
          setTimeout(() => this.scroll_to_top(), 250);
        }
      }
    }
  },

  methods: {
    scroll_to_top (): void {
      if (this.$refs.mailBody?.setSelectionRange) {
        this.$refs.mailBody.focus();
        this.$refs.mailBody.setSelectionRange(0, 0);
        this.$refs.mailBody.scrollTop = 0;
      }
      else if (this.$refs.mailBody?.createTextRange) {
        const range = this.$refs.mailBody.createTextRange();
        range.moveStart('character', 0);
        range.select();
        this.$refs.mailBody.scrollTop = 0;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-menus'

.overall-container
  position: relative

  > .message-header-info
    color: lighten($sp-primary, 10%)
    display: flex
    flex-direction: row
    font-size: 1.15rem
    height: 7.5rem
    padding: .5rem
    width: 100%

    a
      &.button
        text-transform: uppercase
        height: 100%
        font-size: 1.25rem
        letter-spacing: .2rem

    .send-details-column
      display: inline-flex
      flex-direction: column
      flex-grow: 1
      margin-right: .5rem

    .compose-metadata-row
      display: inline-flex
      flex-direction: row
      flex-grow: 1
      justify-content: center
      align-items: center

      span
        color: darken($sp-primary, 5%)
        font-size: .8rem
        letter-spacing: 0.05rem
        margin-right: 1rem
        text-transform: uppercase

      input
        background-color: $sp-dark-bg
        border: 0
        color: $sp-primary
        outline: none

    .send-cancel-column
      margin-right: .5rem
      width: 10rem

    .send-action-column
      width: 10rem


.mail-body-input
  background-color: $sp-dark-bg
  border: 0
  color: $sp-primary
  height: calc(100% - 7.5rem - 3rem - .5rem)
  margin: 0
  outline: none
  overflow-y: scroll
  padding: .5rem
  resize: none
  width: 100%

</style>
