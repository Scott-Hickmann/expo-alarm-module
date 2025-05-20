"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _utils = require("../utils");
class Alarm {
  constructor(params = null) {
    this.uid = (0, _utils.getParam)(params, 'uid');
    this.title = (0, _utils.getParam)(params, 'title');
    this.description = (0, _utils.getParam)(params, 'description');
    this.hour = (0, _utils.getParam)(params, 'hour');
    this.minutes = (0, _utils.getParam)(params, 'minutes');
    this.showDismiss = (0, _utils.getParam)(params, 'showDismiss');
    this.dismissText = (0, _utils.getParam)(params, 'dismissText');
    this.showSnooze = (0, _utils.getParam)(params, 'showSnooze');
    this.snoozeInterval = (0, _utils.getParam)(params, 'snoozeInterval');
    this.snoozeText = (0, _utils.getParam)(params, 'snoozeText');
    this.repeating = (0, _utils.getParam)(params, 'repeating');
    this.active = (0, _utils.getParam)(params, 'active');
    this.day = (0, _utils.getParam)(params, 'day');
  }
  static getEmpty() {
    return new Alarm({
      title: '',
      description: '',
      hour: 0,
      minutes: 0,
      repeating: false,
      day: []
    });
  }
  toAndroid() {
    return {
      ...this,
      day: (0, _utils.toAndroidDays)(this.day)
    };
  }
  static fromAndroid(alarm) {
    alarm.day = (0, _utils.fromAndroidDays)(alarm.day);
    return new Alarm(alarm);
  }
  static fromIos(alarm) {
    if (typeof alarm.day === 'number') {
      alarm.day = (0, _utils.fromIOSDays)(alarm.day);
    }
    return new Alarm(alarm);
  }
}
var _default = exports.default = Alarm;
//# sourceMappingURL=Alarm.js.map