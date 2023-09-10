
export default class HousingDetails {
  type: string;
  vacancies: number;
  average_rent: number;
  quality_index: number;

  constructor (type: string, vacancies: number, average_rent: number, quality_index: number) {
    this.type = type;
    this.vacancies = vacancies;
    this.average_rent = average_rent;
    this.quality_index = quality_index;
  }

  static fromJson (json: any): HousingDetails {
    return new HousingDetails(
      json.type,
      json.vacancies,
      json.averageRent,
      json.qualityIndex
    );
  }
}
