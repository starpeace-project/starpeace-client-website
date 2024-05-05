import tinygradient from 'tinygradient';

import { Translation } from '@starpeace/starpeace-assets-types';

export interface OverlayTypeParameters {
  id: string;
  parentId?: string | undefined;
  gradient?: Array<tinygradient.StopInput> | undefined;
  label: Translation;
}

export default class OverlayType {
  id: string;
  parentId: string | undefined;

  gradient: Array<tinygradient.StopInput> | undefined;
  colorGradient: tinygradient.Instance | undefined;

  label: Translation;

  constructor (parameters: OverlayTypeParameters) {
    this.id = parameters.id;
    this.parentId = parameters.parentId;
    this.gradient = parameters.gradient;
    this.label = parameters.label;

    if (this.gradient && this.gradient.length > 0) {
      this.colorGradient = new tinygradient(this.gradient);
    }
  }

  colorAt (value: number): number {
    return this.colorGradient ? parseInt(this.colorGradient.rgbAt(Math.min(255.0, Math.max(0.0, value)) / 255.0).toHex(), 16) : 0;
  }

  toJson (): any {
    return {
      id: this.id,
      parentId: this.parentId,
      gradient: this.gradient,
      label: this.label.toJson()
    };
  }

  static fromJson (json: any): OverlayType {
    return new OverlayType({
      id: json.id,
      parentId: json.parentId,
      gradient: json.gradient?.map((v: any) => {
        return {
          pos: v.pos,
          color: v.color
        };
      }),
      label: Translation.fromJson(json.label)
    });
  }

}
