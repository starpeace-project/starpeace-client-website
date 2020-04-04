
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class CompanySeal
  constructor: (@id) ->

  @from_json: (json) ->
    seal = new CompanySeal(json.id)
    seal.name_short = Translation.from_json(json.nameShort)
    seal.name_long = Translation.from_json(json.nameLong)
    seal.building_ids = json.buildings || []
    seal

  # @SEALS:
  #   DIS:
  #     id: "DIS"
  #     name: "Dissident"
  #   MAGNA:
  #     id: "MAGNA"
  #     name: "Magna"
  #   MKO:
  #     id: "MKO"
  #     name: "Mariko"
  #   MOAB:
  #     id: "MOAB"
  #     name: "The Moab"
  #   PGI:
  #     id: "PGI"
  #     name: "PGI"
