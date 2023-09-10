export default class ResourceQuantity {
  resource_id: string;
  max_velocity: number;
  weight_efficiency: number;
  weight_quality: number;

  constructor (resource_id: string, max_velocity: number, weight_efficiency: number, weight_quality: number) {
    this.resource_id = resource_id;
    this.max_velocity = max_velocity;
    this.weight_efficiency = weight_efficiency;
    this.weight_quality = weight_quality;
  }

  static fromJson (json: any): ResourceQuantity {
    return new ResourceQuantity(
      json.resourceId,
      json.maxVelocity,
      json.weightEfficiency ?? 0,
      json.weightQuality ?? 0
    );
  }
}
