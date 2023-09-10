import { DateTime }  from 'luxon';

import Candidate from '~/plugins/starpeace-client/planet/politics/candidate'

export default class NextTerm {
  start: DateTime;
  end: DateTime;
  length: number;
  candidates: Array<Candidate> = [];

  constructor (start: DateTime, end: DateTime, length: number, candidates: Array<Candidate>) {
    this.start = start;
    this.end = end;
    this.length = length;
    this.candidates = candidates;
  }

  static fromJson (json: any): NextTerm {
    return new NextTerm(
      DateTime.fromISO(json.start),
      DateTime.fromISO(json.end),
      json.length,
      (json.candidates ?? []).map(Candidate.fromJson)
    );
  }
}