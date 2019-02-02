
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

  @join_with_oxford_comma: (parts, separator) ->
    if parts.length > 2
      last = parts.pop()
      "#{parts.join(', ')}, #{separator} #{last}"
    else
      parts.join(" #{separator} ")

  @parse_query: (query_string) ->
    query = {}
    if query_string?.length
      pairs = (if query_string[0] == '?' then query_string.substr(1) else query_string).split('&')
      for pair in pairs
        query_pair = pair.split('=')
        query[decodeURIComponent(query_pair[0])] = decodeURIComponent(query_pair[1] || '')
    query
