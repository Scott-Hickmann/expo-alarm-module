import Alarm from './models/Alarm';
import { type AlarmSettings } from './types/Alarm.types';
declare function scheduleAlarm(alarm: AlarmSettings): Promise<void>;
declare function enableAlarm(uid: string): Promise<void>;
declare function disableAlarm(uid: string): Promise<void>;
declare function stopAlarm(): Promise<void>;
declare function snoozeAlarm(): Promise<void>;
declare function removeAlarm(uid: string): Promise<void>;
declare function updateAlarm(alarm: AlarmSettings): Promise<void>;
declare function removeAllAlarms(): Promise<void>;
declare function getAllAlarms(): Promise<Alarm[]>;
declare function getAlarm(uid: string): Promise<Alarm | undefined>;
declare function getAlarmState(): Promise<string>;
declare function playAlarm(uid: string): Promise<void>;
declare function multiply(a: number, b: number): Promise<number>;
export default Alarm;
export { scheduleAlarm, enableAlarm, disableAlarm, stopAlarm, snoozeAlarm, removeAlarm, updateAlarm, removeAllAlarms, getAllAlarms, getAlarm, getAlarmState, multiply, playAlarm };
//# sourceMappingURL=index.d.ts.map