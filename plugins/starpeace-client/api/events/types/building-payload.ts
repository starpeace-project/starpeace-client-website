
export default class BuildingPayload {
  id: string;
  constructionProgress: number | undefined;
  cashflow: number;

  constructor (id: string, constructionProgress: number | undefined, cashflow: number) {
    this.id = id;
    this.constructionProgress = constructionProgress;
    this.cashflow = cashflow;
  }

  toJson (): any {
    return {
      i: this.id,
      p: this.constructionProgress,
      f: this.cashflow
    };
  }

  static fromJson (json: any): BuildingPayload {
    return new BuildingPayload(
      json.i,
      json.p,
      json.f ?? 0
    );
  }
}
