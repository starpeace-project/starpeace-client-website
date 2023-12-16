import Logger from '~/plugins/starpeace-client/logger.js';

export default class AjaxState {
  invalidSessionCounter: number = 0;
  invalidSessionAsOf: any | null = null;

  invalidConnectionCounter: number = 0;
  invalidConnectionAsOf: any | null = null;

  ajaxRequests: number = 0;
  requestMutexByTypeKey: Record<string, Record<string, Promise<any>>> = {};

  constructor () {
    this.reset_state();
  }

  reset_state () {
    Logger.deprecated('Using deprecated reset_state');
    this.reset();
  }
  reset () {
    if (this.ajaxRequests > 0) {
      // FIXME: TODO: add better support
      Logger.info("Resetting ajax state with unfinished requests");
    }

    this.invalidSessionCounter = 0;
    this.invalidSessionAsOf = null;

    this.invalidConnectionCounter = 0;
    this.invalidConnectionAsOf = null;

    this.ajaxRequests = 0;
    this.requestMutexByTypeKey = {};
  }

  start_ajax (): void {
    Logger.deprecated('Using deprecated start_ajax');
    this.startAjax();
  }
  startAjax (): void {
    this.ajaxRequests += 1;
  }
  finish_ajax (): void {
    Logger.deprecated('Using deprecated finish_ajax');
    this.finishAjax();
  }
  finishAjax (): void {
    if (this.ajaxRequests > 0) {
      this.ajaxRequests -= 1;
    }
  }

  is_locked (type: string, key: string): boolean {
    Logger.deprecated('Using deprecated is_locked');
    return this.isLocked(type, key);
  }
  isLocked (type: string, key: string): boolean {
    return !!this.requestMutexByTypeKey[type]?.[key];
  }

  lock (type: string, key: string, lockedPromise: Promise<any>) {
    if (!this.requestMutexByTypeKey[type]) {
      this.requestMutexByTypeKey[type] = {};
    }
    this.requestMutexByTypeKey[type][key] = lockedPromise ?? true;
    this.startAjax();
  }

  unlock (type: string, key: string) {
    if (!!this.requestMutexByTypeKey[type]?.[key]) {
      delete this.requestMutexByTypeKey[type][key];
    }
    this.finishAjax();
  }

  async locked (type: string, key: string, callback: () => Promise<any>): Promise<any> {
    const locked_promise = this.requestMutexByTypeKey[type]?.[key];
    if (locked_promise) {
      return await locked_promise;
    }

    const promise = callback();
    this.lock(type, key, promise);
    try {
      const result = await promise;
      this.unlock(type, key);
      return result;
    }
    catch (err) {
      this.unlock(type, key);
      throw err;
    }
  }
}
