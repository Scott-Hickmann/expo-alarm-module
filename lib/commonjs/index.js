"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
exports.disableAlarm = disableAlarm;
exports.enableAlarm = enableAlarm;
exports.getAlarm = getAlarm;
exports.getAlarmState = getAlarmState;
exports.getAllAlarms = getAllAlarms;
exports.multiply = multiply;
exports.removeAlarm = removeAlarm;
exports.removeAllAlarms = removeAllAlarms;
exports.scheduleAlarm = scheduleAlarm;
exports.snoozeAlarm = snoozeAlarm;
exports.stopAlarm = stopAlarm;
exports.updateAlarm = updateAlarm;
var _reactNative = require("react-native");
var _Alarm = _interopRequireDefault(require("./models/Alarm"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
const LINKING_ERROR = `The package 'expo-alarm-module' doesn't seem to be linked. Make sure: \n\n` + _reactNative.Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const ExpoAlarmModule = _reactNative.NativeModules.ExpoAlarmModule ? _reactNative.NativeModules.ExpoAlarmModule : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
async function scheduleAlarm(alarm) {
  let alarmToUse = new _Alarm.default(alarm);
  if (alarmToUse.day instanceof Date) {
    alarmToUse.day = alarmToUse.day.toJSON();
  }
  if (_reactNative.Platform.OS === 'ios') {
    await ExpoAlarmModule.set(alarmToUse);
  } else if (_reactNative.Platform.OS === 'android') {
    await ExpoAlarmModule.set(alarmToUse.toAndroid());
  }
}
async function enableAlarm(uid) {
  await ExpoAlarmModule.enable(uid);
}
async function disableAlarm(uid) {
  await ExpoAlarmModule.disable(uid);
}
async function stopAlarm() {
  await ExpoAlarmModule.stop();
}
async function snoozeAlarm() {
  await ExpoAlarmModule.snooze();
}
async function removeAlarm(uid) {
  await ExpoAlarmModule.remove(uid);
}
async function updateAlarm(alarm) {
  let alarmToUse = new _Alarm.default(alarm);
  if (alarmToUse.day instanceof Date) {
    alarmToUse.day = alarmToUse.day.toJSON();
  }
  await ExpoAlarmModule.update(alarmToUse.toAndroid());
}
async function removeAllAlarms() {
  await ExpoAlarmModule.removeAll();
}
async function getAllAlarms() {
  const alarms = await ExpoAlarmModule.getAll();
  if (alarms && alarms.length > 0) {
    if (_reactNative.Platform.OS === 'ios') {
      let alarmList = [];
      alarms.map(currentAlarm => {
        alarmList.push(_Alarm.default.fromIos(currentAlarm));
      });
      return alarmList;
    } else if (_reactNative.Platform.OS === 'android') {
      return alarms.map(a => _Alarm.default.fromAndroid(a));
    }
  }
  return [];
}
async function getAlarm(uid) {
  const alarm = await ExpoAlarmModule.get(uid);
  if (alarm !== null && alarm !== void 0 && alarm.uid) {
    if (_reactNative.Platform.OS === 'ios') {
      return _Alarm.default.fromIos(alarm);
    } else if (_reactNative.Platform.OS === 'android') {
      return _Alarm.default.fromAndroid(alarm);
    }
  }
  return;
}
async function getAlarmState() {
  return ExpoAlarmModule.getState();
}
function multiply(a, b) {
  return ExpoAlarmModule.multiply(a, b);
}
var _default = exports.default = _Alarm.default;
//# sourceMappingURL=index.js.map