
export default class ServiceRating
  constructor: () ->

  @from_json: (json) ->
    rating = new ServiceRating()
    rating.type = json.type
    rating.delta = json.delta || 0
    rating.rating = json.rating || 0
    rating
