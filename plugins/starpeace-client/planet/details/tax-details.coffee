
export default class TaxDetails
  constructor: () ->

  @from_json: (json) ->
    details = new TaxDetails()
    details.industry_category_id = json.industryCategoryId
    details.industry_type_id = json.industrytypeId
    details.tax_rate = json.taxRate
    details.last_year = json.lastYear
    details
