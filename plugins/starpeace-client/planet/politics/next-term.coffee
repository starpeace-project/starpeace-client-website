import _ from 'lodash';
import { DateTime }  from 'luxon';

import Candidate from '~/plugins/starpeace-client/planet/politics/candidate.coffee'

export default class NextTerm
  constructor: () ->

  @from_json: (json) ->
    term = new NextTerm()
    term.start = DateTime.fromISO(json.start)
    term.end = DateTime.fromISO(json.end)
    term.length = json.length
    term.candidates = _.map(json.candidates, Candidate.from_json)
    term
