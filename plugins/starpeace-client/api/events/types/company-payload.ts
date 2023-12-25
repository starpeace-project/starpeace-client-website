
export default class CompanyPayload {
  id: string;
  cashflow: number;

  constructor (id: string, cashflow: number) {
    this.id = id;
    this.cashflow = cashflow;
  }

  toJson (): any {
    return {
      i: this.id,
      f: this.cashflow
    };
  }

  static fromJson (json: any): CompanyPayload {
    return new CompanyPayload(
      json.i,
      json.f ?? 0
    );
  }
}
