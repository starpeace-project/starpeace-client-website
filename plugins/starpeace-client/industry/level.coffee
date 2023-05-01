
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class Level
  constructor: () ->

  @from_json: (json) ->
    zone = new Level()
    zone.id = json.id
    zone.label = Translation.from_json(json.label)
    zone.description = Translation.from_json(json.description)
    zone.level = json.level || 0
    zone.facilityLimit = json.facilityLimit
    zone.supplierPriority = json.supplierPriority
    zone.supplierIfel = json.supplierIfel
    zone.rewardPrestige = json.rewardPrestige
    zone.refundResearch = json.refundResearch
    zone.refundDemolition = json.refundDemolition
    zone.requiredFee = json.requiredFee
    zone.requiredHourlyProfit = json.requiredHourlyProfit
    zone.requiredPrestige = json.requiredPrestige
    zone
