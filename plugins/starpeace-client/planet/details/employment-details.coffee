
export default class EmploymentDetails
  constructor: () ->

  @from_json: (json) ->
    details = new EmploymentDetails()
    details.type = json.type
    details.vacancies = json.vacancies
    details.spending_power = json.spendingPower
    details.average_wage = json.averageWage
    details.minimum_wage = json.minimumWage
    details
