
export default class Politician {
  id: string;
  name: string;
  prestige: number;
  terms: number;

  constructor (id: string, name: string, prestige: number, terms: number) {
    this.id = id;
    this.name = name;
    this.prestige = prestige;
    this.terms = terms;
  }

  static fromJson (json: any): Politician {
    return new Politician(
      json.id,
      json.name,
      json.prestige,
      json.terms
    );
  }
}