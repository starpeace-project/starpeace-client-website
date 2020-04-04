
export default class Translation
  constructor: () ->

  @from_json = (json) ->
    translation = new Translation()
    if json?
      translation.DE = translation.german = json.DE
      translation.EN = translation.english = json.EN
      translation.ES = translation.spanish = json.ES
      translation.FR = translation.french = json.FR
      translation.IT = translation.italian = json.IT
      translation.PT = translation.portuguese = json.PT
    translation
