
export default class HousingDetails {
  resourceId: string;
  total: number;
  vacancies: number;
  averageRent: number;
  qualityIndex: number;

  constructor (resourceId: string, total: number, vacancies: number, averageRent: number, qualityIndex: number) {
    this.resourceId = resourceId;
    this.total = total;
    this.vacancies = vacancies;
    this.averageRent = averageRent;
    this.qualityIndex = qualityIndex;
  }

  static fromJson (json: any): HousingDetails {
    return new HousingDetails(
      json.resourceId,
      json.total,
      json.vacancies,
      json.averageRent,
      json.qualityIndex
    );
  }
}
