<template lang='pug'>
aside.menu.is-starpeace
  template(v-for='group of optionGroups')
    p.menu-label {{ group.label }}
    ul.menu-list
      li(v-for='option of group.options')
        a(:class="{'is-active': tabId == option.id}" @click.stop.prevent='switchOption(option.id)') {{ option.label }}

</template>

<script lang='ts'>

const OPTION_GROUPS: any = [
  {
    label: 'General',
    options: [
      {
        id: 'DASHBOARD',
        label: 'Dashboard'
      },
      {
        id: 'SIMULATION',
        label: 'Simulation'
      }
    ]
  },
  {
    label: 'Admin',
    options: [
      {
        id: 'TYCOONS',
        label: 'Tycoons'
      },
      {
        id: 'RESEARCH',
        label: 'Research'
      },
      {
        id: 'POLITICS',
        label: 'Politics'
      },
      {
        id: 'BUILDINGS',
        label: 'Buildings'
      }
    ]
  }
]

export default {
  props: {
    tabId: { type: String, require: true }
  },

  computed: {
    optionGroups (): Array<any> {
      return OPTION_GROUPS;
    }
  },

  methods: {
    switchOption (tabId: string): void {
      this.$emit('change', tabId);
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'
@import '~/assets/stylesheets/starpeace-variables'

</style>
