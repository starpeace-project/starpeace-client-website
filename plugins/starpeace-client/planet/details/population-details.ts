
export default class PopulationDetails {
  resourceId: string;
  population: number;
  unemployed: number;
  homeless: number;

  constructor (resourceId: string, population: number, unemployed: number, homeless: number) {
    this.resourceId = resourceId;
    this.population = population;
    this.unemployed = unemployed;
    this.homeless = homeless;
  }

  static fromJson (json: any): PopulationDetails {
    return new PopulationDetails(
      json.resourceId,
      json.population,
      json.unemployed,
      json.homeless
    );
  }
}
