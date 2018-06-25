<template lang='haml'>
#login-container.container
  .card.text-white.bg-info{style: 'margin-bottom: 2rem'}
    .card-body
      Sign in logic is currently in-progress

  .card
    %h5.card-header Sign In to STARPEACE
    .card-body
      %p.card-text Please sign in with one of the following social identity providers.
      %p.card-text STARPEACE Tycoon registration is initiated automatically for new identities.

    .card-body.providers-container
      .providers
        %a.amazon-signin{href: ''}
        .g-signin2{'data-width': '312', 'data-height': '64', 'data-longtitle': 'true', 'data-theme': 'dark'}

    .card-footer.text-center
      %a{href: 'https://www.starpeace.io/privacy.html'} STARPEACE Privacy
</template>

<style lang='sass' scoped>
#login-container
  padding-top: 4rem
  max-width: 600px

  .card-body
    font-size: 1.25rem

  .providers-container
    border-top: 1px solid rgba(0,0,0,.125)

  .providers
    padding: 0 108px
    text-align: center

    a
      &.amazon-signin
        display: inline-block
        height: 64px
        margin-top: 1rem
        width: 312px

        &::before
          content: url('https://images-na.ssl-images-amazon.com/images/G/01/lwa/btnLWA_gry_312x64.png')

        &:active
          &::before
            content: url('https://images-na.ssl-images-amazon.com/images/G/01/lwa/btnLWA_gry_312x64_pressed.png')


    .g-signin2
      margin: 1rem 0
</style>
