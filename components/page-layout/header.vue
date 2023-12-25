<template lang='pug'>
#common-header(v-show='show_header', v-cloak=true)
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

  .welcome.is-hidden-mobile.is-hidden-tablet-only
    span {{$translate('ui.page-layout.header.greeting')}}, {{tycoon_name}}!
    a(v-if='is_authenticated' v-on:click.stop.prevent="logout_tycoon()") ({{$translate('ui.workflow.universe.signout.label')}})

  .development.is-hidden-mobile.is-hidden-tablet-only
    a.header-item.documentation(href='https://docs.starpeace.io') {{$translate('ui.page-layout.header.documentation')}}
    a.header-item.community(href='https://starpeace-project.com/', target='_blank') {{$translate('ui.page-layout.header.community')}}
    misc-language-select(:language_code='language_code', @changed='change_language')
    a.header-item.discord(href='https://discord.gg/TF9Bmsj', target='_blank')
      font-awesome-icon(:icon="['fab', 'discord']")
    a.header-item.github(href='https://github.com/starpeace-project/starpeace-client-website', target='_blank')
      font-awesome-icon(:icon="['fab', 'github']")

</template>

<script lang='ts'>
export default {
  props: {
    client_state: { type: Object, required: true }
  },

  data () {
    return {
      show_header: this.client_state.options?.option('general.show_header') ?? true,
      language_code: this.client_state.options?.language() ?? 'EN'
    };
  },

  mounted () {
    this.client_state.options?.subscribe_options_listener(() => {
      this.show_header = this.client_state.options?.option('general.show_header') ?? true;
      this.language_code = this.client_state.options?.language();
    });
  },

  computed: {
    is_authenticated (): boolean { return !!this.client_state?.identity?.galaxy_tycoon_id; },
    tycoon_name (): string { return this.is_authenticated ? this.client_state?.identity?.galaxy_tycoon_name : this.$translate('identity.visitor'); }
  },

  methods: {
    change_language (code: string): void {
      this.client_state.options.setLanguage(code);
    },

    async logout_tycoon (): void {
      if (!this.client_state?.identity?.galaxy_id || !this.managers?.galaxy_manager) return;
      try {
        await this.managers.galaxy_manager.logout(this.client_state?.identity?.galaxy_id);
        this.client_state.reset_full_state();
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

  .welcome
    float: left
    margin: .25rem 0 0 .5rem

    span
      margin-right: 1rem

  .development
    float: right
    padding-top: .25rem

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
