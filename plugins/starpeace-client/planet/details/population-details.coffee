
export default class PopulationDetails
  constructor: () ->

  @from_json: (json) ->
    details = new PopulationDetails()
    details.type = json.type
    details.population = json.population
    details.unemployed = json.unemployed
    details.homeless = json.homeless
    details
