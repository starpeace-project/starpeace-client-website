###
* main logic
###

CLIENT_VERSION = "0.1.0"

window.starpeace ||= {}
window.starpeace.globals ||= {}

window.starpeace.globals.meter = null
window.starpeace.globals.client = null

animate = () ->
  window.starpeace.globals.client.tick() if window.starpeace.globals.client?
  requestAnimationFrame(-> animate())


$ ->
  if $('#application').length
    window.starpeace.globals.client = new starpeace.Client()
    console.debug "[starpeace] client v#{CLIENT_VERSION} created"
    animate()

  $('[data-toggle="tooltip"]').tooltip()

  # google analytics
  window.dataLayer = window.dataLayer || []
  gtag = () -> dataLayer.push(arguments)
  gtag('js', new Date())
  gtag('config', 'UA-120729341-2')
