import _ from 'lodash';

export default class EventListener {

  listeners: Record<string, Function[]> = {};

  subscribe (type: string, callback: Function) {
    if (!_.isFunction(callback)) {
      throw new Error("callback must be a method");
    }
    if (!this.listeners[type]) {
      this.listeners[type] = [];
    }
    this.listeners[type].push(callback);
  }

  notify_listeners (type: string, callback_data=null) {
    setTimeout(() => {
      for (const listener of (this.listeners[type] ?? [])) {
        setTimeout((() => listener(callback_data)), 0);
      }
    }, 5);
  }

}
