import _ from 'lodash'
import moment from 'moment'

import Candidate from '~/plugins/starpeace-client/planet/politics/candidate.coffee'

export default class NextTerm
  constructor: () ->

  @from_json: (json) ->
    term = new NextTerm()
    term.start = moment(json.start)
    term.end = moment(json.end)
    term.length = json.length
    term.candidates = _.map(json.candidates, Candidate.from_json)
    term
