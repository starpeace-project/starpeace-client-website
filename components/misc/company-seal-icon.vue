<template lang='haml'>
  %span.company-seal-icon-wrapper
    %template{'v-if':"seal_id == 'DIS'"}
      %font-awesome-icon{':icon':"['fab', 'bimobject']", flip:'horizontal'}
    %template{'v-else-if':"seal_id == 'MAGNA'"}
      %font-awesome-icon{':icon':"['fab', 'megaport']"}
    %template{'v-else-if':"seal_id == 'MKO'"}
      %font-awesome-icon{':icon':"['fab', 'monero']"}
    %template{'v-else-if':"seal_id == 'MOAB'"}
      %font-awesome-icon{':icon':"['fab', 'mizuni']"}
    %template{'v-else-if':"seal_id == 'PGI'"}
      %font-awesome-icon{':icon':"['fas', 'parking']"}
    %template{'v-else-if':"true"}
      %font-awesome-icon{':icon':"['far', 'circle']"}
</template>

<script lang='coffee'>
export default
  name: 'company-seal-icon'
  props:
    seal_id: String
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.company-seal-icon-wrapper
  height: 1.2rem
  width: 1.2rem

</style>
