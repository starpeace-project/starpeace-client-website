
const CLIENT_VERSION = process?.env?.CLIENT_VERSION ?? '0.0.0';

export default class Logger {

  static banner (): void {
    const BANNER_HEADER_FONT = 'font-family:monospace;font-size:16px;';
    const BANNER_HEADER_BACKGROUND = 'background-color:#000;color:#FFF';
    const BANNER_HEADER_FOREGROUND = 'background-color:#395950;color:#6ea192;font-weight:bold';
    const BANNER_VERSION_FOREGROUND = 'background-color:#000;color:#fff;font-weight:bold';
    const BANNER_NOTES_FOREGROUND = 'background-color:#000;color:#fff;font-weight:normal';

    let version_text = CLIENT_VERSION;
    while (version_text.length < 86) {
      version_text = ` ${version_text} `;
    }
    if (version_text.length < 87) {
      version_text = ` ${version_text}`;
    }

    const banner_text = "%c%c###########################################################################################\n" +
        "##                                                                                       ##\n" +
        "##  %c███████╗████████╗ █████╗ ██████╗  ███╗███╗ ██████╗ ███████╗ █████╗  ██████╗███████╗%c  ##\n" +
        "##  %c██╔════╝╚══██╔══╝██╔══██╗██╔══██╗ ███║███║ ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝%c  ##\n" +
        "##  %c███████╗   ██║   ███████║██████╔╝ ╚══╝╚██║ ██████╔╝█████╗  ███████║██║     █████╗%c    ##\n" +
        "##  %c╚════██║   ██║   ██╔══██║██╔══██╗ ████╗╚█║ ██╔═══╝ ██╔══╝  ██╔══██║██║     ██╔══╝%c    ##\n" +
        "##  %c███████║   ██║   ██║  ██║██║  ██║ █████╗╚╝ ██║     ███████╗██║  ██║╚██████╗███████╗%c  ##\n" +
        "##  %c╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝%c  ##\n" +
        "##                                                                                       ##\n" +
        "###########################################################################################\n" +
        `##%c${version_text}%c##\n` +
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

    console.debug(`%c[STARPEACE]%c client %c${CLIENT_VERSION}%c created`, 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;', 'font-weight:bold;text-decoration:underline', 'font-weight:normal;text-decoration:none');
  }

  static warn (message: string): void {
    console.warn(`%c[STARPEACE]%c ${message}`, 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;');
  }

  static info (message: string): void {
    console.log(`%c[STARPEACE]%c ${message}`, 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;');
  }

  static debug (message: string): void {
    console.debug(`%c[STARPEACE]%c ${message}`, 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;');
  }

  static deprecated (message: string): void {
    console.debug(`%c[STARPEACE]%c ${message}`, 'font-size:16px;line-height:20px;background-color:#395950;color:#fff', 'background-color:#fff;color:#000;line-height:20px;');
  }
}
