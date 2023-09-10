
export default class Candidate {
  id: string;
  name: string;
  prestige: number;
  votes: number;

  constructor (id: string, name: string, prestige: number, votes: number) {
    this.id = id;
    this.name = name;
    this.prestige = prestige;
    this.votes = votes;
  }

  static fromJson (json: any): Candidate {
    return new Candidate(
      json.id,
      json.name,
      json.prestige,
      json.votes
    );
  }
}
