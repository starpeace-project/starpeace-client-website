<template lang='pug'>
#common-header(v-show='show_header' v-cloak=true)
  .common-logo.not-mobile.is-hidden-mobile
    a.logo(href='/')
      h1 STAR
      img.starpeace-logo
      h1 PEACE
  .common-logo.mobile.is-hidden-tablet
    a.logo(href='/')
      h1 STAR
      img.starpeace-logo
      h1 PEACE

  .welcome.is-flex-grow-1.is-hidden-mobile.is-hidden-tablet-only.mt-1.ml-2
    template(v-if='isAuthenticated')
      span {{ $translate('ui.page-layout.header.greeting') }}, {{ authenticatedUsername }}!
      a.ml-3(@click.stop.prevent='logoutTycoon') ({{ $translate('ui.workflow.universe.signout.label') }})
    template(v-else)
      span {{ $translate('ui.page-layout.header.greeting') }}, {{ $translate('identity.visitor') }}!

  .development.is-hidden-mobile.is-hidden-tablet-only.pt-1
    a.header-item.documentation(href='https://docs.starpeace.io') {{ $translate('ui.page-layout.header.documentation') }}
    a.header-item.community(href='https://docs.starpeace.io/reference/project' target='_blank') {{ $translate('ui.page-layout.header.community') }}
    misc-language-select(:language_code='language_code' @changed='change_language')
    a.header-item.discord(href='https://discord.gg/TF9Bmsj' target='_blank' rel='noreferer')
      font-awesome-icon(:icon="['fab', 'discord']")
    a.header-item.github(href='https://github.com/starpeace-project/starpeace-client-website' target='_blank' rel='noreferer')
      font-awesome-icon(:icon="['fab', 'github']")

</template>

<script lang='ts'>
import type Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data () {
    return {
      show_header: this.clientState.options?.option('general.show_header') ?? true,
      language_code: this.clientState.options?.language() ?? 'EN'
    };
  },

  mounted () {
    this.clientState.options?.subscribe_options_listener(() => {
      this.show_header = this.clientState.options?.option('general.show_header') ?? true;
      this.language_code = this.clientState.options?.language();
    });
  },

  computed: {
    isAuthenticated (): boolean {
      return !!this.clientState?.identity?.galaxy_tycoon_id || this.hasRefreshTokenTycoon;
    },
    hasRefreshTokenTycoon (): boolean {
      return !!this.clientState.options.authentication.galaxyUsername && !!this.clientState.options.authentication.galaxyToken;
    },

    authenticatedUsername (): string | undefined {
      return this.clientState?.identity?.galaxy_tycoon_name ?? this.clientState.options.authentication.galaxyUsername;
    },
    authenticatedGalaxyId (): string | undefined {
      return this.clientState?.identity?.galaxy_id ?? this.clientState.options.authentication.galaxyId;
    }
  },

  methods: {
    change_language (code: string): void {
      this.clientState.options.setLanguage(code);
    },

    async logoutTycoon (): Promise<void> {
      try {
        if (this.clientState?.identity?.galaxy_id) {
          await this.$starpeaceClient.managers.galaxy_manager.logout(this.clientState.identity.galaxy_id);
        }

        this.clientState.reset_full_state();
        this.clientState.options.authentication.clear_authorization_state();
      }
      catch (err) {
        console.error(err);
        this.$forceUpdate();
      }
    }
  }
}
</script>

<style lang='sass' scoped>
#common-header
  color: #fff
  display: flex
  font-size: 1.25rem
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: start-header
  grid-row-end: end-header
  line-height: 3rem
  padding-top: .25rem
  z-index: 2000

  .common-logo
    float: left

    .starpeace-logo
      filter: brightness(0) saturate(100%) invert(100%) sepia(1%) saturate(7498%) hue-rotate(205deg) brightness(105%) contrast(100%)
      background-size: 2.5rem
      display: inline-block
      height: 2.5rem
      margin: 0 0 .5rem
      width: 2.5rem
      vertical-align: middle

    h1
      display: inline-block
      font-size: 3rem
      line-height: 3rem
      margin: .25rem .25rem .5rem
      vertical-align: middle

      &:not(:first-child)
        margin-left: .5rem

    &.mobile
      padding: 2vw 1vw 1vw
      text-align: center
      width: 100%

      .starpeace-logo
        background-size: 9vw
        height: 9vw
        margin: 0 0 .5rem
        width: 9vw

      h1
        font-size: 11vw

  a
    color: #fff

  .development
    .header-item
      display: inline-block
      line-height: 3rem
      margin: 0 1rem
      vertical-align: bottom

      &.discord,
      &.twitter,
      &.github
        font-size: 1.4rem

      &.twitter
        line-height: 2.95rem

      &.discord
        line-height: 2.9rem
</style>
