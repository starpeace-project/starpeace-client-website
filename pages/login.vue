<template lang='haml'>
  %section.container
    %div
      %login-panel

</template>

<script lang='coffee'>
import LoginPanel from '~/components/login-panel.vue'

export default
  components:
    'login-panel': LoginPanel

</script>

<style lang='sass'>
</style>
