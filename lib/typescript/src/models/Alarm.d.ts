declare class Alarm {
    uid?: string | undefined;
    title?: string | undefined;
    description?: string | undefined;
    hour?: number | undefined;
    minutes?: number | undefined;
    showDismiss?: boolean | undefined;
    dismissText?: string | undefined;
    showSnooze?: boolean | undefined;
    snoozeInterval?: number | undefined;
    snoozeText?: string | undefined;
    repeating?: boolean | undefined;
    active?: boolean | undefined;
    day?: string | Date | number[] | undefined;
    constructor(params?: any);
    static getEmpty(): Alarm;
    toAndroid(): this & {
        day: string | Date | number[];
    };
    static fromAndroid(alarm: Alarm): Alarm;
    static fromIos(alarm: Alarm): Alarm;
}
export default Alarm;
//# sourceMappingURL=Alarm.d.ts.map