import { NativeModules, Platform } from 'react-native';
import Alarm from './models/Alarm';
const LINKING_ERROR = `The package 'expo-alarm-module' doesn't seem to be linked. Make sure: \n\n` + Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const ExpoAlarmModule = NativeModules.ExpoAlarmModule ? NativeModules.ExpoAlarmModule : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
async function scheduleAlarm(alarm) {
  let alarmToUse = new Alarm(alarm);
  if (alarmToUse.day instanceof Date) {
    alarmToUse.day = alarmToUse.day.toJSON();
  }
  if (Platform.OS === 'ios') {
    await ExpoAlarmModule.set(alarmToUse);
  } else if (Platform.OS === 'android') {
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
  let alarmToUse = new Alarm(alarm);
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
    if (Platform.OS === 'ios') {
      let alarmList = [];
      alarms.map(currentAlarm => {
        alarmList.push(Alarm.fromIos(currentAlarm));
      });
      return alarmList;
    } else if (Platform.OS === 'android') {
      return alarms.map(a => Alarm.fromAndroid(a));
    }
  }
  return [];
}
async function getAlarm(uid) {
  const alarm = await ExpoAlarmModule.get(uid);
  if (alarm !== null && alarm !== void 0 && alarm.uid) {
    if (Platform.OS === 'ios') {
      return Alarm.fromIos(alarm);
    } else if (Platform.OS === 'android') {
      return Alarm.fromAndroid(alarm);
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
export default Alarm;
export { scheduleAlarm, enableAlarm, disableAlarm, stopAlarm, snoozeAlarm, removeAlarm, updateAlarm, removeAllAlarms, getAllAlarms, getAlarm, getAlarmState, multiply };
//# sourceMappingURL=index.js.map