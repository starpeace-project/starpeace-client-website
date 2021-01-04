
export default class Candidate
  constructor: () ->

  @from_json: (json) ->
    candidate = new Candidate()
    candidate.id = json.id
    candidate.name = json.name
    candidate.prestige = json.prestige
    candidate.votes = json.votes
    candidate
