import _ from 'lodash'
import moment from 'moment'

import Politician from '~/plugins/starpeace-client/planet/politics/politician.coffee'
import ServiceRating from '~/plugins/starpeace-client/planet/politics/service-rating.coffee'

export default class CurrentTerm
  constructor: () ->

  @from_json: (json) ->
    term = new CurrentTerm()
    term.start = moment(json.start)
    term.end = moment(json.end)
    term.length = json.term
    term.politician = if json.politician? then Politician.from_json(json.politician) else null
    term.overall_rating = json.overallRating
    term.service_ratings = _.map(json.serviceRatings, ServiceRating.from_json)
    term
