
export default class BudgetDetails {
  cash: number;

  constructor (cash: number) {
    this.cash = cash;
  }

  static fromJson (json: any): BudgetDetails {
    return new BudgetDetails(
      json.cash
    );
  }
}
