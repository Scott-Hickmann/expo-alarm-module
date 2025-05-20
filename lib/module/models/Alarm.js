import { toAndroidDays, fromAndroidDays, getParam, fromIOSDays } from '../utils';
class Alarm {
  constructor(params = null) {
    this.uid = getParam(params, 'uid');
    this.title = getParam(params, 'title');
    this.description = getParam(params, 'description');
    this.hour = getParam(params, 'hour');
    this.minutes = getParam(params, 'minutes');
    this.showDismiss = getParam(params, 'showDismiss');
    this.dismissText = getParam(params, 'dismissText');
    this.showSnooze = getParam(params, 'showSnooze');
    this.snoozeInterval = getParam(params, 'snoozeInterval');
    this.snoozeText = getParam(params, 'snoozeText');
    this.repeating = getParam(params, 'repeating');
    this.active = getParam(params, 'active');
    this.day = getParam(params, 'day');
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
      day: toAndroidDays(this.day)
    };
  }
  static fromAndroid(alarm) {
    alarm.day = fromAndroidDays(alarm.day);
    return new Alarm(alarm);
  }
  static fromIos(alarm) {
    if (typeof alarm.day === 'number') {
      alarm.day = fromIOSDays(alarm.day);
    }
    return new Alarm(alarm);
  }
}
export default Alarm;
//# sourceMappingURL=Alarm.js.map