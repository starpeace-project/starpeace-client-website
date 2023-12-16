
export default class EmploymentDetails {
  resourceId: string;
  total: number;
  vacancies: number;
  spendingPower: number;
  averageWage: number;
  minimumWage: number;

  constructor (resourceId: string, total: number, vacancies: number, spendingPower: number, averageWage: number, minimumWage: number) {
    this.resourceId = resourceId;
    this.total = total;
    this.vacancies = vacancies;
    this.spendingPower = spendingPower;
    this.averageWage = averageWage;
    this.minimumWage = minimumWage;
  }

  static fromJson (json: any): EmploymentDetails {
    return new EmploymentDetails(
      json.resourceId,
      json.total,
      json.vacancies,
      json.spendingPower,
      json.averageWage,
      json.minimumWage
    );
  }
}
