
export default class Politician
  constructor: () ->

  @from_json: (json) ->
    politician = new Politician()
    politician.id = json.id
    politician.name = json.name
    politician.prestige = json.prestige
    politician.terms = json.terms
    politician
