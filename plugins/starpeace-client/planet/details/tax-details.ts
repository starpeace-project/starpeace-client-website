
export default class TaxDetails {
  industry_category_id: string;
  industry_type_id: string;
  tax_rate: number;
  last_year: number;

  constructor (industry_category_id: string, industry_type_id: string, tax_rate: number, last_year: number) {
    this.industry_category_id = industry_category_id;
    this.industry_type_id = industry_type_id;
    this.tax_rate = tax_rate;
    this.last_year = last_year;
  }

  static fromJson (json: any): any {
    return new TaxDetails(
      json.industryCategoryId,
      json.industrytypeId,
      json.taxRate,
      json.lastYear
    );
  }
}
