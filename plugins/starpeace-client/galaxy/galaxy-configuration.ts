
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
}
