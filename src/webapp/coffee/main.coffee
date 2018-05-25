###
* main logic
###

meter = null

animate = () ->
  meter.tickStart() if meter?

  requestAnimationFrame(-> animate())
  meter.tick() if meter?


$ ->
  meter = new FPSMeter({
    theme: 'colorful'
    top: '70px'
  })

  animate()
