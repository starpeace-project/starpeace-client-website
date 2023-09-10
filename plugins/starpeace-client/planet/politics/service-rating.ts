
export default class ServiceRating {
  type: string;
  delta: number;
  rating: number;

  constructor (type: string, delta: number, rating: number) {
    this.type = type;
    this.delta = delta;
    this.rating = rating;
  }

  static fromJson (json: any): ServiceRating {
    return new ServiceRating(
      json.type,
      json.delta ?? 0,
      json.rating ?? 0
    );
  }
}
