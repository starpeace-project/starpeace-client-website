
export default class Utils {

  static s4 (): string {
    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  }
  static uuid (): string {
    return `${Utils.s4()}${Utils.s4()}-${Utils.s4()}-${Utils.s4()}-${Utils.s4()}-${Utils.s4()}${Utils.s4()}${Utils.s4()}`;
  }

  static pixels_for_image (image: any): Uint8ClampedArray {
    const canvas = document.createElement('canvas');
    canvas.width = image.width;
    canvas.height = image.height;

    const context = canvas.getContext('2d');
    if (context) {
      context.drawImage(image, 0, 0, image.width, image.height);
      return context.getImageData(0, 0, image.width, image.height).data;
    }
    return new Uint8ClampedArray();
  }

  static format_money (value: number | undefined | null, decimals=0): string {
    return (value ?? 0).toFixed(0).replace(new RegExp('\\d(?=(\\d{3})+$)', 'g'), '$&,');
  }

  static join_with_oxford_comma (parts: Array<string>, separator: string): string {
    if (parts.length > 2) {
      const last = parts.pop();
      return `${parts.join(', ')}, ${separator} ${last}`;
    }
    else {
      return parts.join(` ${separator} `);
    }
  }

  static parse_query (query_string: string): Record<string, string> {
    const query: Record<string, string> = {};
    if (query_string?.length) {
      const pairs = (query_string[0] == '?' ? query_string.substr(1) : query_string).split('&');
      for (const pair of pairs) {
        const query_pair = pair.split('=');
        query[decodeURIComponent(query_pair[0])] = decodeURIComponent(query_pair[1] || '')
      }
    }
    return query;
  }

  static grid_style (tag: string, values: Array<any>): string {
    let style = '';
    for (let index = 0; index < values.length; index++) {
      if (index === 0) {
        style = `[${values[index].start}]`;
      }
      style = `${style} ${values[index].size}`;
      style = `${style} [${[values[index].end].concat(index < values.length - 1 ? [values[index + 1].start] : []).join(' ')}]`;
    }
    return `${tag}: ${style}`;
  }
}
