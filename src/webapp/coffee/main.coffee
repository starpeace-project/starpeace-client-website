###
* main logic
###

CLIENT_VERSION = "0.1.0"

window.starpeace ||= {}
window.starpeace.globals ||= {}

window.starpeace.globals.meter = null
window.starpeace.globals.client = null

animate = () ->
  window.starpeace.globals.meter.tickStart() if window.starpeace.globals.meter?
  window.starpeace.globals.client.tick() if window.starpeace.globals.client?

  requestAnimationFrame(-> animate())
  window.starpeace.globals.meter.tick() if window.starpeace.globals.meter?


$ ->
  window.starpeace.globals.meter = new FPSMeter({
    theme: 'colorful'
    top: '70px'
  })

  animate()

  window.starpeace.globals.client = new starpeace.Client()
  console.debug "[starpeace] client v#{CLIENT_VERSION} created"

  $('[data-toggle="tooltip"]').tooltip()
