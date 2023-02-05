import _ from 'lodash';

import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class CompanySeal
  constructor: (@id) ->

  @from_json: (json) ->
    seal = new CompanySeal(json.id)
    seal.name_short = json.nameShort
    seal.name_long = json.nameLong
    seal.descriptions = _.map(json.descriptions, Translation.from_json)
    seal.playable = json.playable || false
    seal.pros = Translation.from_json(json.pros) if json.pros?
    seal.cons = Translation.from_json(json.cons) if json.cons?
    seal.strengths = Translation.from_json(json.strengths) if json.strengths?
    seal.weaknesses = Translation.from_json(json.weaknesses) if json.weaknesses?
    seal.building_ids = json.buildingIds || []
    seal
