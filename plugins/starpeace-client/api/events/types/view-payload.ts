
export default class ViewPayload {
  x: number;
  y: number;

  constructor (x: number, y: number) {
    this.x = x;
    this.y = y;
  }

  toJson (): any {
    return {
      x: this.x,
      y: this.y
    };
  }

  static fromJson (json: any): ViewPayload {
    return new ViewPayload(
      json.x,
      json.y
    );
  }
}
