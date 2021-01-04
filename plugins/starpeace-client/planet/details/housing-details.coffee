
export default class HousingDetails
  constructor: () ->

  @from_json: (json) ->
    details = new HousingDetails()
    details.type = json.type
    details.vacancies = json.vacancies
    details.average_rent = json.averageRent
    details.quality_index = json.qualityIndex
    details
