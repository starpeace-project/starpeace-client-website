
export default class Translation {
  textByCode: Record<string, string>;

  constructor (textByCode: Record<string, string>) {
    this.textByCode = textByCode;
  }

  get DE (): string | undefined {
    return this.textByCode['DE'];
  }
  get EN (): string | undefined {
    return this.textByCode['EN'];
  }
  get ES (): string | undefined {
    return this.textByCode['ES'];
  }
  get FR (): string | undefined {
    return this.textByCode['FR'];
  }
  get IT (): string | undefined {
    return this.textByCode['IT'];
  }
  get PT (): string | undefined {
    return this.textByCode['PT'];
  }

  get german (): string | undefined {
    return this.textByCode['DE'];
  }
  get english (): string | undefined {
    return this.textByCode['EN'];
  }
  get spanish (): string | undefined {
    return this.textByCode['ES'];
  }
  get french (): string | undefined {
    return this.textByCode['FR'];
  }
  get italian (): string | undefined {
    return this.textByCode['IT'];
  }
  get portuguese (): string | undefined {
    return this.textByCode['PT'];
  }

  static from_json (json: any): Translation {
    return Translation.fromJson(json);
  }
  static fromJson (json: any): Translation {
    return new Translation({
      DE: json.DE ?? '',
      EN: json.EN ?? '',
      ES: json.ES ?? '',
      FR: json.FR ?? '',
      IT: json.IT ?? '',
      PT: json.PT ?? ''
    });
  }
}
