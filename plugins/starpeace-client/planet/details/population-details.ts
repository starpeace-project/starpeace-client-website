
export default class PopulationDetails {
  type: string;
  population: number;
  unemployed: number;
  homeless: number;

  constructor (type: string, population: number, unemployed: number, homeless: number) {
    this.type = type;
    this.population = population;
    this.unemployed = unemployed;
    this.homeless = homeless;
  }

  static fromJson (json: any): PopulationDetails {
    return new PopulationDetails(
      json.type,
      json.population,
      json.unemployed,
      json.homeless
    );
  }
}
