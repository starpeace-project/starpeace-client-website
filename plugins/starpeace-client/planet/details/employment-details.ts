
export default class EmploymentDetails {
  type: string;
  vacancies: number;
  spending_power: number;
  average_wage: number;
  minimum_wage: number;

  constructor (type: string, vacancies: number, spending_power: number, average_wage: number, minimum_wage: number) {
    this.type = type;
    this.vacancies = vacancies;
    this.spending_power = spending_power;
    this.average_wage = average_wage;
    this.minimum_wage = minimum_wage;
  }

  static fromJson (json: any): EmploymentDetails {
    return new EmploymentDetails(
      json.type,
      json.vacancies,
      json.spendingPower,
      json.averageWage,
      json.minimumWage
    );
  }
}
