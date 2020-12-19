import _ from 'lodash'

import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class RankingType
  constructor: () ->

  @from_json: (json) ->
    type = new RankingType()
    type.id = json.id
    type.parent_id = json.parentId
    type.type = json.type
    type.category_total = json.categoryTotal || false
    type.unit = json.unit
    type.label = Translation.from_json(json.label) if json.label?
    type.industry_category_id = json.industryCategoryId
    type.industry_type_id = json.industryTypeId
    type.children = _.map(json.children, RankingType.from_json)
    type
