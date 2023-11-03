import SinkConnection from '~/plugins/starpeace-client/building/details/sink-connection';

export default class Product {
  resourceId: string;
  price: number;
  totalVelocity: number;
  quality: number;
  connections: Array<SinkConnection>;

  constructor (resourceId: string, price: number, total_velocity: number, quality: number, connections: Array<SinkConnection>) {
    this.resourceId = resourceId;
    this.price = price;
    this.totalVelocity = total_velocity;
    this.quality = quality;
    this.connections = connections;
  }

  static fromJson (json: any): Product {
    return new Product(
      json.resourceId,
      json.price,
      json.totalVelocity,
      json.quality,
      (json.connections ?? []).map(SinkConnection.fromJson)
    );
  }
}
