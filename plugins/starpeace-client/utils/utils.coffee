
export default class Utils

  @s4: () -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
  @uuid: () -> "#{Utils.s4()}#{Utils.s4()}-#{Utils.s4()}-#{Utils.s4()}-#{Utils.s4()}-#{Utils.s4()}#{Utils.s4()}#{Utils.s4()}"

  @pixels_for_image: (image) ->
    canvas = document.createElement('canvas')
    canvas.width = image.width
    canvas.height = image.height

    context = canvas.getContext('2d')
    context.drawImage(image, 0, 0, image.width, image.height)
    context.getImageData(0, 0, image.width, image.height).data

  @format_money: (value, decimals=0) ->
    value.toFixed(0).replace(new RegExp('\\d(?=(\\d{3})+$)', 'g'), '$&,')
