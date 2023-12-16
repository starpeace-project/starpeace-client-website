<template lang='pug'>
.overall-container

  .tabs.is-centered.is-toggle.is-fullwidth.sp-tabs
    ul
      li(:class="{'is-active':mode=='CONTACTS'}")
        a(:class="{'disabled': loading}" @click.stop.prevent="mode='CONTACTS'") Contacts
      li(:class="{'is-active':mode=='ALLIES'}")
        a(:class="{'disabled': loading}" @click.stop.prevent="mode='ALLIES'") Allies
      li(:class="{'is-active':mode=='BLOCKED'}")
        a(:class="{'disabled': loading}" @click.stop.prevent="mode='BLOCKED'") Blocked

  aside.sp-scrollbar

  .level.is-mobile.sp-actions-container.is-bottom
    .level-item.action-column
      button.button.is-small.is-fullwidth.is-starpeace(disabled='disabled') {{$translate('ui.menu.mail.contacts.action.organize')}}
    .level-item.action-column
      button.button.is-small.is-fullwidth.is-starpeace(@click.stop.prevent='show_add_contact' :disabled='actions_disabled') {{$translate('ui.menu.mail.contacts.action.add')}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true },

    loading: Boolean
  },

  data () {
    return {
      menu_visible: this.client_state?.menu?.is_visible('mail'),
      mode: 'CONTACTS'
    };
  },

  mounted () {
    this.client_state?.menu?.subscribe_menu_listener(() => {
      this.menu_visible = this.client_state?.menu?.is_visible('mail') ?? false;
    })
  },

  computed: {
    is_ready (): boolean { return this.client_state.workflow_status === 'ready'; },
    has_corporation () { return this.is_ready && this.client_state.is_tycoon() && this.client_state.player.corporation_id?.length > 0; },

    actions_disabled () { return !(this.is_ready && this.has_corporation && !this.loading); }
  },

  methods: {
    show_add_contact () {
      console.log('show add contact');
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-menus'

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
