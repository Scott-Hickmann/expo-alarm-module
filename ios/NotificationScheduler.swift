import Foundation
import UIKit
import UserNotifications
import AVFoundation

class NotificationScheduler : NotificationSchedulerDelegate
{
    private let alarms: Alarms = Store.shared.alarms
    // we need to request user for notifiction permission first
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            (authorized, _) in
            if authorized {
                print("notification authorized")
            } else {
                // may need to try other way to make user authorize your app
                print("not authorized")
            }
        }
    }
    
    
    func registerNotificationCategories() {
        // Define the custom actions
        let snoozeAction = UNNotificationAction(identifier: Identifier.snoozeActionIdentifier, title: "Snooze", options: [.foreground])
        let stopAction = UNNotificationAction(identifier: Identifier.stopActionIdentifier, title: "OK", options: [.foreground])
        
        let snoonzeActions = [snoozeAction, stopAction]
        let nonSnoozeActions = [stopAction]
        
        let snoozeAlarmCategory = UNNotificationCategory(identifier: Identifier.snoozeAlarmCategoryIndentifier,
                                                         actions: snoonzeActions,
                                                         intentIdentifiers: [],
                                                         hiddenPreviewsBodyPlaceholder: "",
                                                         options: .customDismissAction)

        let nonSnoozeAlarmCategroy = UNNotificationCategory(identifier: Identifier.alarmCategoryIndentifier,
                                                            actions: nonSnoozeActions,
                                                            intentIdentifiers: [],
                                                            hiddenPreviewsBodyPlaceholder: "",
                                                            options: .customDismissAction)
        // Register the notification category
        UNUserNotificationCenter.current().setNotificationCategories([snoozeAlarmCategory, nonSnoozeAlarmCategroy])
    }
    
    // sync alarm state to scheduled notifications for some situation (app in background and user didn't click notification to bring the app to foreground) that
    // alarm state is not updated correctly
    func syncAlarmStateWithNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {
            requests in
            print(requests)
            let alarms = Store.shared.alarms
            let uuidNotificationsSet = Set(requests.map({$0.content.userInfo["uid"] as! String}))
            let uuidAlarmsSet = alarms.uids
            let uuidDeltaSet = uuidAlarmsSet.subtracting(uuidNotificationsSet)
            
            for uid in uuidDeltaSet {
                if let alarm = alarms.getAlarm(ByUUIDStr: uid) {
                    if alarm.active {
                        alarm.active = false
                        // since this method will cause UI change, make sure run on main thread
                        DispatchQueue.main.async {
                            alarms.update(alarm)
                        }
                    }
                }
            }
        })
    }
    
    private func getNotificationDates(baseDate date: Date) -> [Date]
    {
        var notificationDates: [Date] = [] // initialize empty array to avoid unintended immediate schedules
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let now = Date()
        let flags: NSCalendar.Unit = [NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.day]
        let dateComponents = (calendar as NSCalendar).components(flags, from: date)
        
        // scheduling date is earlier than current date
        if date < now {
            notificationDates.append((calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: 1, to: date, options:.matchStrictly)!)
        } else {
            notificationDates.append(date)
        }
        print("[NotificationScheduler] getNotificationDates: baseDate=\(date), now=\(now), dates=\(notificationDates)")
        return notificationDates
    }
    
    static func correctSecondComponent(date: Date, calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)) -> Date {
        let second = calendar.component(.second, from: date)
        let d = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.second, value: -second, to: date, options:.matchStrictly)!
        return d
    }
    
    func setNotification(alarm: Alarm) {
        print("[NotificationScheduler] setNotification called for alarm uid=\(alarm.uid), date=\(alarm.date)")
        let datesForNotification = getNotificationDates(baseDate: alarm.date)
        // Load sound duration from bundle
        guard let soundURL = Bundle.main.url(forResource: "bell", withExtension: "mp3") else {
            print("[NotificationScheduler] Could not find bell.mp3 in bundle")
            return
        }
        let asset = AVURLAsset(url: soundURL)
        let duration = CMTimeGetSeconds(asset.duration)
        print("[NotificationScheduler] bell.mp3 duration: \(duration) seconds")
        
        for d in datesForNotification {
            for index in 0..<20 {
                let fireDate = d.addingTimeInterval(duration * Double(index))
                let content = UNMutableNotificationContent()
                content.title = alarm.title
                content.body = alarm.description
                content.categoryIdentifier = alarm.snoozeEnabled ? Identifier.snoozeAlarmCategoryIndentifier : Identifier.alarmCategoryIndentifier
                content.sound = UNNotificationSound(named: UNNotificationSoundName("bell.mp3"))
                content.userInfo = ["snooze": alarm.snoozeEnabled, "uid": alarm.uid, "soundName": "bell"]
                
                let timeInterval = fireDate.timeIntervalSince(Date())
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval, 1), repeats: false)
                let identifier = "\(alarm.uid)_\(index)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let e = error {
                        print("[NotificationScheduler] Error scheduling notification \(identifier): \(e.localizedDescription)")
                    } else {
                        print("[NotificationScheduler] Scheduled notification \(identifier) for id=\(alarm.uid) at \(fireDate)")
                    }
                }
            }
        }
    }
    
    func setNotificationForSnooze(ringtoneName: String, snoozeMinute: Int, uid: String) {
        let currentAlarm = alarms.getAlarm(ByUUIDStr: uid);
        if(currentAlarm != nil) {
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let now = Date()
            let snoozeDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: snoozeMinute, to: now, options:.matchStrictly)!
            setNotification(alarm: currentAlarm!)
        } else {
            print("Error when setting notification for snooze")
        }
    }
    
    func cancelNotification(ByUUIDStr uid: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests.compactMap { req -> String? in
                guard let rUid = req.content.userInfo["uid"] as? String, rUid == uid else { return nil }
                return req.identifier
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        }
    }
    
    func updateNotification(ByUUIDStr uid: String, date: Date, ringtoneName: String, snoonzeEnabled: Bool) {
        cancelNotification(ByUUIDStr: uid)
        let currentAlarm = alarms.getAlarm(ByUUIDStr: uid);
        if(currentAlarm != nil) {
            setNotification(alarm: currentAlarm!)
        } else {
            print("Error updating notification")
        }
    }
    
    enum weekdaysComparisonResult {
        case before
        case same
        case after
    }
    
    // 1 == Sunday, 2 == Monday and so on
    func compare(weekday w1: Int, with w2: Int) -> weekdaysComparisonResult
    {
        if w1 != 1 && (w1 < w2 || w2 == 1) {return .before}
        else if w1 == w2 {return .same}
        else {return .after}
    }
}
