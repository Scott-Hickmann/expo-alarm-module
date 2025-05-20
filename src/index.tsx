import { NativeModules, Platform } from 'react-native';
import Alarm from './models/Alarm';
import { type AlarmSettings } from './types/Alarm.types';

const LINKING_ERROR =
  `The package 'expo-alarm-module' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ExpoAlarmModule = NativeModules.ExpoAlarmModule
  ? NativeModules.ExpoAlarmModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

async function scheduleAlarm(alarm: AlarmSettings) {
  console.log('[expo-alarm-module] scheduleAlarm called with', alarm);
  let alarmToUse: Alarm = new Alarm(alarm);
  console.log('[expo-alarm-module] Alarm object created:', alarmToUse);

  if (alarmToUse.day instanceof Date) {
    alarmToUse.day = alarmToUse.day.toJSON();
  }
  console.log(`[expo-alarm-module] Scheduling on ${Platform.OS} for day: ${alarmToUse.day}`);
  if (Platform.OS === 'ios') {
    await ExpoAlarmModule.set(alarmToUse);
  } else if (Platform.OS === 'android') {
    await ExpoAlarmModule.set(alarmToUse.toAndroid());
  }
  console.log('[expo-alarm-module] scheduleAlarm completed for uid:', alarmToUse.uid);
}

async function enableAlarm(uid: string) {
  await ExpoAlarmModule.enable(uid);
}

async function disableAlarm(uid: string) {
  await ExpoAlarmModule.disable(uid);
}

async function stopAlarm() {
  await ExpoAlarmModule.stop();
}

async function snoozeAlarm() {
  await ExpoAlarmModule.snooze();
}

async function removeAlarm(uid: string) {
  await ExpoAlarmModule.remove(uid);
}

async function updateAlarm(alarm: AlarmSettings) {
  let alarmToUse: Alarm = new Alarm(alarm);

  if (alarmToUse.day instanceof Date) {
    alarmToUse.day = alarmToUse.day.toJSON();
  }

  await ExpoAlarmModule.update(alarmToUse.toAndroid());
}

async function removeAllAlarms() {
  await ExpoAlarmModule.removeAll();
}

async function getAllAlarms(): Promise<Alarm[]> {
  const alarms = await ExpoAlarmModule.getAll();

  if (alarms && alarms.length > 0) {
    if (Platform.OS === 'ios') {
      let alarmList: Alarm[] = [];
      alarms.map((currentAlarm: Alarm) => {
        alarmList.push(Alarm.fromIos(currentAlarm));
      });
      return alarmList;
    } else if (Platform.OS === 'android') {
      return alarms.map((a: any) => Alarm.fromAndroid(a));
    }
  }
  return [];
}

async function getAlarm(uid: string) {
  const alarm = await ExpoAlarmModule.get(uid);

  if (alarm?.uid) {
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

async function playAlarm(uid: string): Promise<void> {
  console.log('[expo-alarm-module] playAlarm called for', uid);
  await ExpoAlarmModule.playAlarm(uid);
}

function multiply(a: number, b: number): Promise<number> {
  return ExpoAlarmModule.multiply(a, b);
}

export default Alarm;
export { scheduleAlarm, enableAlarm, disableAlarm, stopAlarm, snoozeAlarm, removeAlarm, updateAlarm, removeAllAlarms, getAllAlarms, getAlarm, getAlarmState, multiply, playAlarm };
