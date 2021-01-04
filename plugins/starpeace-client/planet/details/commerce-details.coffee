
export default class CommerceDetails
  constructor: () ->

  @from_json: (json) ->
    details = new CommerceDetails()
    details.industry_type_id = json.industryTypeId
    details.demand = json.demand
    details.supply = json.supply
    details.capacity = json.capacity
    details.ratio = json.ratio
    details.ifel_price = json.ifelPrice
    details.average_price = json.averagePrice
    details.quality = json.quality
    details
