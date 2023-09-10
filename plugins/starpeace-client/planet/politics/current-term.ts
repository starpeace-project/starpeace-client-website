import { DateTime }  from 'luxon';

import Politician from '~/plugins/starpeace-client/planet/politics/politician'
import ServiceRating from '~/plugins/starpeace-client/planet/politics/service-rating'

export default class CurrentTerm {
  start: DateTime;
  end: DateTime;
  length: number;
  politician: Politician | undefined;
  overall_rating: number;
  service_ratings: Array<ServiceRating> = [];

  constructor (start: DateTime, end: DateTime, length: number, politician: Politician | undefined, overall_rating: number, service_ratings: Array<ServiceRating>) {
    this.start = start;
    this.end = end;
    this.length = length;
    this.politician = politician;
    this.overall_rating = overall_rating;
    this.service_ratings = service_ratings;
  }

  static fromJson (json: any): CurrentTerm {
    return new CurrentTerm(
      DateTime.fromISO(json.start),
      DateTime.fromISO(json.end),
      json.term,
      json.politician ? Politician.fromJson(json.politician) : undefined,
      json.overallRating,
      (json.serviceRatings ?? []).map(ServiceRating.fromJson)
    );
  }
}
