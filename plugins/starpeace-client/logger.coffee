
CLIENT_VERSION = process.env.CLIENT_VERSION

class Logger
  constructor: () ->

  @banner: () ->
    console.log("%c[STARPEACE]%c client %c#{process.env.CLIENT_VERSION}%c created", 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;', 'font-weight:bold;text-decoration:underline', 'font-weight:normal;text-decoration:none')

  @info: (message) ->
    console.log("%c[STARPEACE]%c #{message}", 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;')

  @debug: (message) ->
    console.debug("%c[STARPEACE]%c #{message}", 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;')

export default Logger
