
CLIENT_VERSION = process.env.CLIENT_VERSION

export default class Logger
  constructor: () ->

  @banner: () ->
    BANNER_HEADER_FONT = 'font-family:monospace;font-size:16px;'
    BANNER_HEADER_BACKGROUND = 'background-color:#000;color:#FFF'
    BANNER_HEADER_FOREGROUND = 'background-color:#395950;color:#6ea192;font-weight:bold'
    BANNER_VERSION_FOREGROUND = 'background-color:#000;color:#fff;font-weight:bold'
    BANNER_NOTES_FOREGROUND = 'background-color:#000;color:#fff;font-weight:normal'

    version_text = process.env.CLIENT_VERSION
    version_text = " #{version_text} " while version_text.length < 86
    version_text = " #{version_text}" if version_text.length < 87

    banner_text = "%c%c###########################################################################################\n" +
        "##                                                                                       ##\n" +
        "##  %c███████╗████████╗ █████╗ ██████╗  ███╗███╗ ██████╗ ███████╗ █████╗  ██████╗███████╗%c  ##\n" +
        "##  %c██╔════╝╚══██╔══╝██╔══██╗██╔══██╗ ███║███║ ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝%c  ##\n" +
        "##  %c███████╗   ██║   ███████║██████╔╝ ╚══╝╚██║ ██████╔╝█████╗  ███████║██║     █████╗%c    ##\n" +
        "##  %c╚════██║   ██║   ██╔══██║██╔══██╗ ████╗╚█║ ██╔═══╝ ██╔══╝  ██╔══██║██║     ██╔══╝%c    ##\n" +
        "##  %c███████║   ██║   ██║  ██║██║  ██║ █████╗╚╝ ██║     ███████╗██║  ██║╚██████╗███████╗%c  ##\n" +
        "##  %c╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝%c  ##\n" +
        "##                                                                                       ##\n" +
        "###########################################################################################\n" +
        "##%c#{version_text}%c##\n" +
        "###########################################################################################\n" +
        "##                                                                                       ##\n" +
        "##         %c please report all security vulnerabilities to security@starpeace.io %c         ##\n" +
        "##                                                                                       ##\n" +
        "## %cinterested in contributing? any and all help is gladly welcome! please join STARPEACE%c ##\n" +
        "## %cDiscord chatroom or visit starpeace-project Github organization for more information!%c ##\n" +
        "##                                                                                       ##\n" +
        "###########################################################################################\n"

    console.log(banner_text, BANNER_HEADER_FONT, BANNER_HEADER_BACKGROUND,
        BANNER_HEADER_FOREGROUND, BANNER_HEADER_BACKGROUND,
        BANNER_HEADER_FOREGROUND, BANNER_HEADER_BACKGROUND,
        BANNER_HEADER_FOREGROUND, BANNER_HEADER_BACKGROUND,
        BANNER_HEADER_FOREGROUND, BANNER_HEADER_BACKGROUND,
        BANNER_HEADER_FOREGROUND, BANNER_HEADER_BACKGROUND,
        BANNER_HEADER_FOREGROUND, BANNER_HEADER_BACKGROUND,

        BANNER_VERSION_FOREGROUND, BANNER_HEADER_BACKGROUND,

        BANNER_NOTES_FOREGROUND, BANNER_HEADER_BACKGROUND,
        BANNER_NOTES_FOREGROUND, BANNER_HEADER_BACKGROUND,
        BANNER_NOTES_FOREGROUND, BANNER_HEADER_BACKGROUND
    )

    console.debug("%c[STARPEACE]%c client %c#{process.env.CLIENT_VERSION}%c created", 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;', 'font-weight:bold;text-decoration:underline', 'font-weight:normal;text-decoration:none')

  @warn: (message) ->
    console.log("%c[STARPEACE]%c #{message}", 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;')

  @info: (message) ->
    console.log("%c[STARPEACE]%c #{message}", 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;')

  @debug: (message) ->
    console.debug("%c[STARPEACE]%c #{message}", 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;')
