
export default class EmploymentDetails {
  resourceId: string;
  total: number;
  vacancies: number;
  averageWage: number;
  minimumWage: number;

  constructor (resourceId: string, total: number, vacancies: number, averageWage: number, minimumWage: number) {
    this.resourceId = resourceId;
    this.total = total;
    this.vacancies = vacancies;
    this.averageWage = averageWage;
    this.minimumWage = minimumWage;
  }

  static fromJson (json: any): EmploymentDetails {
    return new EmploymentDetails(
      json.resourceId,
      json.total,
      json.vacancies,
      json.averageWage,
      json.minimumWage
    );
  }
}
