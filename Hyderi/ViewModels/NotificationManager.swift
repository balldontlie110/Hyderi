//
//  NotificationManager.swift
//  Hyderi
//
//  Created by Ali Earp on 12/30/24.
//

import SwiftUI
import UserNotifications
import iCalendarParser

class NotificationManager {
    static func requestAuthorization(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            guard success, error == nil else {
                if let settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                
                return
            }
            
            completion()
        }
    }
}

extension EventModel {
    static func scheduleNotification(for event: ICEvent, eventTime: EventTime, completion: @escaping (EventTime) -> Void) {
        removePendingNotifications(for: event)
        
        guard let summary = event.summary, let location = location(from: event.location), let start = event.date(), let triggerDate = eventTime.addingTime(to: start) else {
            completion(.none)
            
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = [summary, eventTime.notificationString].joined(separator: " ")
        content.body = location
        content.userInfo = ["eventTime": eventTime.rawValue]
        
        let triggerComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.uid, content: content, trigger: trigger)
        
        NotificationManager.requestAuthorization {
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else {
                    completion(.none)
                    
                    return
                }
                
                completion(eventTime)
            }
        }
    }
    
    private static func removePendingNotifications(for event: ICEvent) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.uid])
    }
    
    static func isNotifying(event: ICEvent) async -> EventTime {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        guard let rawValue = requests.first(where: { $0.identifier == event.uid })?.content.userInfo["eventTime"] as? Int, let eventTime = EventTime(rawValue: rawValue) else {
            return .none
        }
        
        return eventTime
    }
}

extension PrayerTimeModel {
    var prayerTimeNotifications: [Prayer : Bool] {
        get {
            guard let prayerTimeNotificationsData = prayerTimeNotificationsString.data(using: .utf8) else { return [:] }
            
            do {
                let prayerTimeNotifications = try JSONDecoder().decode([String : Bool].self, from: prayerTimeNotificationsData)
                
                return Dictionary(uniqueKeysWithValues: prayerTimeNotifications.compactMap({ prayerTimeNotification in
                    guard let prayer = Prayer(name: prayerTimeNotification.key) else { return nil }
                    
                    return (prayer, prayerTimeNotification.value)
                }))
            } catch {
                return [:]
            }
        } set {
            do {
                let prayerTimeNotifications = Dictionary(uniqueKeysWithValues: newValue.map({ ($0.key.rawValue, $0.value) }))
                
                if let prayerTimeNotificationsString = String(data: try JSONEncoder().encode(prayerTimeNotifications), encoding: .utf8) {
                    self.prayerTimeNotificationsString = prayerTimeNotificationsString
                    
                    PrayerTimeModel.scheduleNotifications(for: prayerTimeNotificationsString)
                }
            } catch {
                print(error)
            }
        }
    }
    
    static func scheduleNotifications(for prayerTimeNotifications: String) {
        removePendingNotifications()
        
        PrayerTimeModel.fetchPrayerTimesToday { prayerTimes in
            let activePrayerTimeNotifications = self.fetchActivePrayerTimeNotifications(from: prayerTimeNotifications)
            
            let prayerTimes = prayerTimes.filter({ activePrayerTimeNotifications.contains($0.key) })
            
            NotificationManager.requestAuthorization {
                for (prayer, time) in prayerTimes {
                    let content = UNMutableNotificationContent()
                    content.title = "\(prayer.formatted) \(prayer.isPrayer ? "Salaat" : "")"
                    content.body = "\(prayer.emoji) \(prayer.formatted) at \(time.time())"
                    content.sound = prayer.isPrayer ? UNNotificationSound(named: UNNotificationSoundName("Adhan.wav")) : .default
                    
                    let triggerComponents = Calendar.current.dateComponents([.minute, .hour], from: time)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: prayer.rawValue, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
    
    private static func removePendingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: Prayer.allCases.map({ $0.rawValue }))
    }
    
    private static func fetchActivePrayerTimeNotifications(from prayerTimeNotifications: String) -> [Prayer] {
        guard let prayerTimeNotificationsData = prayerTimeNotifications.data(using: .utf8) else { return [] }
        
        do {
            let prayerTimeNotifications = try JSONDecoder().decode([String : Bool].self, from: prayerTimeNotificationsData)
            
            return prayerTimeNotifications.filter({ $0.value == true }).keys.compactMap({ Prayer(name: $0) })
        } catch {
            return []
        }
    }
}
