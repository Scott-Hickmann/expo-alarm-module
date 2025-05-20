import Foundation

class Alarm: Codable {
    let uid: String
    var date: Date
    var active: Bool
    var snoozeEnabled: Bool
    var title: String
    var description: String
    
    convenience init() {
        self.init(uid: "", date: Date(), active: true, snoozeEnabled: false, title: "Alarm", description: "")
    }
    
    init(uid: String, date: Date, active: Bool, snoozeEnabled: Bool, title: String, description: String) {
        self.uid = uid
        self.date = date
        self.active = active
        self.snoozeEnabled = snoozeEnabled
        self.title = title
        self.description = description
    }
    
    init(dictionary: NSMutableDictionary) {
        // Parses the day which can be a timestamp or ISO date string
        if let dayValue = dictionary["day"] {
            if let seconds = dayValue as? TimeInterval {
                self.date = Date(timeIntervalSince1970: seconds)
            } else if let dateString = dayValue as? String {
                var parsedDate: Date?
                if #available(iOS 10.0, *) {
                    parsedDate = ISO8601DateFormatter().date(from: dateString)
                }
                if parsedDate == nil {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    parsedDate = df.date(from: dateString)
                }
                self.date = parsedDate ?? Date()
            } else {
                self.date = Date()
            }
        } else {
            self.date = Date()
        }
        
        self.uid = dictionary["uid"] as? String ?? "";
        self.active = dictionary["active"] as? Bool ?? false;
        self.snoozeEnabled = dictionary["snoozeEnabled"] as? Bool ?? false
        self.title = dictionary["title"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
    }
    
    enum CodingKeys: CodingKey {
        case uid
        case date
        case active
        case snoozeEnabled
        case title
        case description
    }
    
    required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Alarm.CodingKeys> = try decoder.container(keyedBy: Alarm.CodingKeys.self)
        
        self.uid = try container.decode(String.self, forKey: Alarm.CodingKeys.uid)
        self.date = try container.decode(Date.self, forKey: Alarm.CodingKeys.date)
        self.active = try container.decode(Bool.self, forKey: Alarm.CodingKeys.active)
        self.snoozeEnabled = try container.decode(Bool.self, forKey: Alarm.CodingKeys.snoozeEnabled)
        self.title = try container.decode(String.self, forKey: Alarm.CodingKeys.title)
        self.description = try container.decode(String.self, forKey: Alarm.CodingKeys.description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Alarm.CodingKeys> = encoder.container(keyedBy: Alarm.CodingKeys.self)
        
        try container.encode(self.uid, forKey: Alarm.CodingKeys.uid)
        try container.encode(self.date, forKey: Alarm.CodingKeys.date)
        try container.encode(self.active, forKey: Alarm.CodingKeys.active)
        try container.encode(self.snoozeEnabled, forKey: Alarm.CodingKeys.snoozeEnabled)
        try container.encode(self.title, forKey: Alarm.CodingKeys.title)
        try container.encode(self.description, forKey: Alarm.CodingKeys.description)
    }
    
    func toDictionary() -> NSDictionary {
        let alarm: Alarm = self;
        
        let alarmDictionary: NSDictionary = [
            "uid": alarm.uid,
            "day": alarm.date.timeIntervalSince1970,
            "active": alarm.active,
            "snoozeEnabled": alarm.snoozeEnabled,
            "title": alarm.title,
            "description": alarm.description
        ]
        
        return alarmDictionary;
    }
}

extension Alarm {
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self.date)
    }
}

extension Alarm {
    static let changeReasonKey = "reason"
    static let newValueKey = "newValue"
    static let oldValueKey = "oldValue"
    static let updated = "updated"
    static let added = "added"
    static let removed = "removed"
}
