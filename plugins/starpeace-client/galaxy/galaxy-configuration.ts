
export default class GalaxyConfiguration {
  id: string;
  protocol: string;
  host: string;
  port: number;

  constructor (id: string, protocol: string, host: string, port: number) {
    this.id = id;
    this.protocol = protocol;
    this.host = host;
    this.port = port;
  }

  get api_protocol (): string {
    return this.protocol;
  }
  get api_url (): string {
    return this.host;
  }
  get api_port (): number {
    return this.port;
  }

  get hash (): string {
    return btoa(`${this.id}|${this.protocol}|${this.host}|${this.port}`);
  }

  static fromHash (hash: string | undefined): GalaxyConfiguration | undefined {
    const parts = hash ? atob(hash).split('|') : [];
    if (parts.length === 4) {
      return new GalaxyConfiguration(parts[0], parts[1], parts[2], parseInt(parts[3]));
    }
    return undefined;
  }
}
