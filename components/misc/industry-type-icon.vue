<template lang='haml'>
  %span.industry-type-icon-wrapper
    %template{'v-if':"industry_type == 'AUTOMOBILE'"}
      %img{src: '~/assets/images/icons/industries/car.svg'}
    %template{'v-else-if':"industry_type == 'BANKING'"}
      %img{src: '~/assets/images/icons/services/safebox.svg'}
    %template{'v-else-if':"industry_type == 'BAR'"}
      %img{src: '~/assets/images/icons/commerce/beer.svg'}
    %template{'v-else-if':"industry_type == 'BOOK'"}
      %img{src: '~/assets/images/icons/industries/book.svg'}
    %template{'v-else-if':"industry_type == 'CHEMICAL'"}
      %img{src: '~/assets/images/icons/industries/chemistry.svg'}
    %template{'v-else-if':"industry_type == 'CLOTHES'"}
      %img{src: '~/assets/images/icons/industries/shirt.svg'}
    %template{'v-else-if':"industry_type == 'COAL'"}
      %img{src: '~/assets/images/icons/industries/wagon.svg'}
    %template{'v-else-if':"industry_type == 'COMPACT_DISC'"}
      %img{src: '~/assets/images/icons/industries/compact-disc.svg'}
    %template{'v-else-if':"industry_type == 'COMPUTER'"}
      %img{src: '~/assets/images/icons/industries/laptop.svg'}
    %template{'v-else-if':"industry_type == 'COMPUTER_SERVICES'"}
      %img{src: '~/assets/images/icons/services/service-company.svg'}
    %template{'v-else-if':"industry_type == 'CONSTRUCTION'"}
      %img{src: '~/assets/images/icons/industries/construction.svg'}
    %template{'v-else-if':"industry_type == 'CRUDE_OIL'"}
      %img{src: '~/assets/images/icons/industries/oil.svg'}
    %template{'v-else-if':"industry_type == 'ELECTRIC_COMPONENT'"}
      %img{src: '~/assets/images/icons/industries/microchip.svg'}
    %template{'v-else-if':"industry_type == 'FABRIC'"}
      %img{src: '~/assets/images/icons/industries/cloth.svg'}
    %template{'v-else-if':"industry_type == 'FAST_FOOD'"}
      %img{src: '~/assets/images/icons/commerce/fast-food.svg'}
    %template{'v-else-if':"industry_type == 'FARMING'"}
      %img{src: '~/assets/images/icons/industries/wheat.svg'}
    %template{'v-else-if':"industry_type == 'FUNERAL_SERVICES'"}
      %img{src: '~/assets/images/icons/services/tombstone.svg'}
    %template{'v-else-if':"industry_type == 'FURNITURE'"}
      %img{src: '~/assets/images/icons/industries/furniture.svg'}
    %template{'v-else-if':"industry_type == 'GASOLINE'"}
      %img{src: '~/assets/images/icons/commerce/gas-station.svg'}
    %template{'v-else-if':"industry_type == 'HOUSEHOLD_APPLIANCE'"}
      %img{src: '~/assets/images/icons/industries/hha.svg'}
    %template{'v-else-if':"industry_type == 'HEADQUARTERS'"}
      %img{src: '~/assets/images/icons/services/headquarters.svg'}
    %template{'v-else-if':"industry_type == 'LEGAL_SERVICES'"}
      %img{src: '~/assets/images/icons/services/legal.svg'}
    %template{'v-else-if':"industry_type == 'LIQUOR'"}
      %img{src: '~/assets/images/icons/industries/whiskey.svg'}
    %template{'v-else-if':"industry_type == 'MACHINERY'"}
      %img{src: '~/assets/images/icons/industries/cogwheel.svg'}
    %template{'v-else-if':"industry_type == 'MARKET'"}
      %img{src: '~/assets/images/icons/commerce/shop.svg'}
    %template{'v-else-if':"industry_type == 'METAL'"}
      %img{src: '~/assets/images/icons/industries/beam.svg'}
    %template{'v-else-if':"industry_type == 'MOVIE'"}
      %img{src: '~/assets/images/icons/industries/clapboard.svg'}
    %template{'v-else-if':"industry_type == 'OFFICE'"}
      %img{src: '~/assets/images/icons/offices/office-block.svg'}
    %template{'v-else-if':"industry_type == 'ORE'"}
      %img{src: '~/assets/images/icons/industries/wagon.svg'}
    %template{'v-else-if':"industry_type == 'PAPER'"}
      %img{src: '~/assets/images/icons/industries/cloth.svg'}
    %template{'v-else-if':"industry_type == 'PHARMACEUTICAL'"}
      %img{src: '~/assets/images/icons/industries/medicine.svg'}
    %template{'v-else-if':"industry_type == 'PLASTIC'"}
      %img{src: '~/assets/images/icons/industries/flask.svg'}
    %template{'v-else-if':"industry_type == 'PROCESSED_FOOD'"}
      %img{src: '~/assets/images/icons/industries/canned-food.svg'}
    %template{'v-else-if':"industry_type == 'RAW_CHEMICAL'"}
      %img{src: '~/assets/images/icons/industries/wagon.svg'}
    %template{'v-else-if':"industry_type == 'RESIDENTIAL'"}
      %img{src: '~/assets/images/icons/residentials/building.svg'}
    %template{'v-else-if':"industry_type == 'RESTAURANT'"}
      %img{src: '~/assets/images/icons/commerce/store-front.svg'}
    %template{'v-else-if':"industry_type == 'SILICON'"}
      %img{src: '~/assets/images/icons/industries/wagon.svg'}
    %template{'v-else-if':"industry_type == 'STONE'"}
      %img{src: '~/assets/images/icons/industries/wagon.svg'}
    %template{'v-else-if':"industry_type == 'TELEVISION'"}
      %img{src: '~/assets/images/icons/services/television.svg'}
    %template{'v-else-if':"industry_type == 'TIMBER'"}
      %img{src: '~/assets/images/icons/industries/chainsaw.svg'}
    %template{'v-else-if':"industry_type == 'TOY'"}
      %img{src: '~/assets/images/icons/industries/toy.svg'}
    %template{'v-else-if':"true"}
      %img{src: '~/assets/images/icons/general/test-tubes.svg'}
</template>

<script lang='coffee'>
export default
  name: 'industry-type-icon'
  props:
    industry_type: String
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.industry-type-icon-wrapper
  img
    filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
    height: 1.2rem
    width: 1.2rem

.is-active
  img
    filter: invert(100%)

</style>
