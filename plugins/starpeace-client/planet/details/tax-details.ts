
export default class TaxDetails {
  industryCategoryId: string;
  industryTypeId: string;
  taxRate: number;
  lastYear: number;

  constructor (industryCategoryId: string, industryTypeId: string, taxRate: number, lastYear: number) {
    this.industryCategoryId = industryCategoryId;
    this.industryTypeId = industryTypeId;
    this.taxRate = taxRate;
    this.lastYear = lastYear;
  }

  static fromJson (json: any): any {
    return new TaxDetails(
      json.industryCategoryId,
      json.industryTypeId,
      json.taxRate,
      json.lastYear
    );
  }
}
