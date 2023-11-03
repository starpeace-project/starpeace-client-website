import Labor from '~/plugins/starpeace-client/building/details/labor';
import Product from '~/plugins/starpeace-client/building/details/product';

export default class BuildingDetails {
  id: string;
  products: Array<Product>;
  labors: Array<Labor>;

  constructor (id: string, products: Array<Product>, labors: Array<Labor>) {
    this.id = id;
    this.products = products;
    this.labors = labors;
  }

  static fromJson (json: any): BuildingDetails {
    return new BuildingDetails(
      json.id,
      (json.products ?? []).map(Product.fromJson),
      (json.labors ?? []).map(Labor.fromJson)
    );
  }
}
