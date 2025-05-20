import EventKit
import AVFoundation

@objc(ExpoAlarmModule)
class ExpoAlarmModule: NSObject, UNUserNotificationCenterDelegate, AVAudioPlayerDelegate  {
    var isEditMode = false
    public static var audioPlayer: AVAudioPlayer?
    
    private let notificationScheduler: NotificationSchedulerDelegate = NotificationScheduler()
    private let manager: Manager = Manager();
    
    public override init() {
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch let error as NSError{
            print("could not set session. err:\(error.localizedDescription)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError{
            print("could not active session. err:\(error.localizedDescription)")
        }
        
        notificationScheduler.requestAuthorization()
        notificationScheduler.registerNotificationCategories()
        UNUserNotificationCenter.current().delegate = self

        // Add observer for applicationDidBecomeActive
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc(multiply:withB:withResolver:withRejecter:)
    func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        resolve((a*b))
    }

    @objc(set:withResolver:withRejecter:)
    func set(alarm: NSDictionary, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        let alarmToUse = Alarm(dictionary: NSMutableDictionary(dictionary: alarm));


        manager.schedule(alarmToUse);    

        resolve(nil)
    }

    @objc(enable:withResolver:withRejecter:)
    func enable(uid: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        manager.enable(uid)
        
        resolve(nil)
    }

    @objc(disable:withResolver:withRejecter:)
    func disable(uid: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        manager.disable(uid)
        
        resolve(nil)
    }


    @objc(stop)
    func stop() -> Void {
        manager.stop();
    }

    @objc(get:withResolver:withRejecter:)
    func get(uid: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        let alarm: Alarm! = manager.getAlarm(uid);
        if(alarm != nil) {
            let alarmSerialized: NSDictionary = alarm.toDictionary();
            resolve(alarmSerialized)
        } else {
            resolve(nil)
        }
    }
    
    @objc(getAll:withRejecter:)
    func getAll(resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        let alarmArray: [Alarm] = manager.getAllAlarms();
    
        let alarmDictionaryArray = alarmArray.map { alarm -> NSDictionary in
            return alarm.toDictionary()
        }
        
        if(alarmArray.count > 0) {
            resolve(alarmDictionaryArray)
        } else {
            resolve(nil)
        }    }

    @objc(remove:withResolver:withRejecter:)
    func remove(uid: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        manager.remove(uid)
        
        resolve(nil)
    }
    
    @objc(removeAll:withRejecter:)
    func removeAll(resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        manager.removeAll();
        
        resolve(nil)
    }
    
    @objc(getState:withRejecter:)
    func getState(resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        resolve(manager.getCurrentPlayingAlarm())
    }

    @objc(playAlarm:withResolver:withRejecter:)
    func playAlarm(_ uid: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        // Added verbose logging and safety stop to prevent overlapping audio
        print("[ExpoAlarmModule] playAlarm called for uid=\(uid)")
        // Stop any existing alarm sound before starting a new one
        manager.stop()

        // Ensure current alarm is marked playing
        manager.setCurrentPlayingAlarm(uid)

        // Play and loop the alarm sound
        self.playSound("bell")

        resolve(nil)
    }

    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Verbose logging for diagnostic purposes
        print("[ExpoAlarmModule] willPresent received notification: \(notification.request.identifier)")

        //show an alert window
        let alertController = UIAlertController(title: "Alarm", message: nil, preferredStyle: .alert)
        let userInfo = notification.request.content.userInfo
        guard
            let snoozeEnabled = userInfo["snooze"] as? Bool,
            let soundName = userInfo["soundName"] as? String,
            let uidStr = userInfo["uid"] as? String
        else {
            completionHandler([])
            return
        }

        // Stop any existing audio before starting a new one to avoid overlaps
        manager.stop()

        manager.setCurrentPlayingAlarm(uidStr)
        playSound(soundName)
        //schedule notification for snooze
        if snoozeEnabled {
            let snoozeOption = UIAlertAction(title: "Snooze", style: .default) {
                (action:UIAlertAction) in
                self.manager.stop()
                self.notificationScheduler.setNotificationForSnooze(ringtoneName: soundName, snoozeMinute: 9, uid: uidStr)
            }
            alertController.addAction(snoozeOption)
        }
        
        let stopOption = UIAlertAction(title: "OK", style: .default) {
            (action:UIAlertAction) in
            self.manager.stop()
            let alarms = Store.shared.alarms
        }
        
        alertController.addAction(stopOption)

        // Do NOT include `.sound` here to prevent the system from playing the notification
        // sound on top of our custom looping playback. This eliminates the "double sound"
        // and ensures that calling manager.stop() will silence the alarm immediately.
        if #available(iOS 14.0, *) {
            completionHandler([.list])
        } else {
            completionHandler([.alert])
        }
    }
    

    @objc func applicationDidBecomeActive() {
        notificationScheduler.syncAlarmStateWithNotification()
    }

    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard
            let soundName = userInfo["soundName"] as? String,
            let uid = userInfo["uid"] as? String
        else {return}
        
        switch response.actionIdentifier {
        case Identifier.snoozeActionIdentifier:
            // notification fired when app in background, snooze button clicked
            notificationScheduler.setNotificationForSnooze(ringtoneName: soundName, snoozeMinute: 9, uid: uid)
            break
        case Identifier.stopActionIdentifier:
            // notification fired when app in background, stop action clicked
            // stop any playing alarm sound
            manager.stop()
            // clear current playing alarm state
            manager.setCurrentPlayingAlarm(nil)
            // cancel any pending notification for this alarm
            notificationScheduler.cancelNotification(ByUUIDStr: uid)
            break
        default:
            // User tapped the notification itself to open the app
            manager.setCurrentPlayingAlarm(uid)
            // Start native looping playback of the alarm sound
            self.playSound(soundName)
            break
        }

        completionHandler()
    }
    
    //AlarmApplicationDelegate protocol
    func playSound(_ soundName: String) {
        //vibrate phone first
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
            nil,
            { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            },
            nil)
        
        guard let filePath = Bundle.main.path(forResource: soundName, ofType: "mp3") else {fatalError()}
        let url = URL(fileURLWithPath: filePath)
        
        do {
            ExpoAlarmModule.audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            ExpoAlarmModule.audioPlayer = nil
            print("audioPlayer error \(error.localizedDescription)")
            return
        }
        
        if let player = ExpoAlarmModule.audioPlayer {
            player.delegate = self
            player.prepareToPlay()
            //negative number means loop infinity
            player.numberOfLoops = -1
            player.play()
        }
    }
}
