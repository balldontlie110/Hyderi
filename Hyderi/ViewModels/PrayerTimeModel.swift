//
//  PrayerTimeModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/8/24.
//

import SwiftUI
import Alamofire
import SwiftSoup

class PrayerTimeModel: ObservableObject {
    @Published var prayerTimes: [[[Prayer : Date]]] = []
    
    @AppStorage("prayerTimeNotifications") var prayerTimeNotificationsString: String = "{\"Dawn\": false, \"Sunrise\": false, \"Noon\": false, \"Sunset\": false, \"Maghrib\": false}"
    
    init() {
        PrayerTimeModel.fetchPrayerTimes { prayerTimes in
            self.prayerTimes = prayerTimes
        }
    }
    
    static func fetchPrayerTimes(completion: @escaping ([[[Prayer : Date]]]) -> Void) {
        AF.request("https://najaf.org/english/prayer/london/?cachebust=\(UUID().uuidString)").responseString { response in
            do {
                let html = try response.result.get()
                let document = try SwiftSoup.parse(html)
                
                let months = try document.select("table.my-table.small")
                
                var prayerTimes: [[[Prayer : Date]]] = []
                
                for month in months {
                    var monthPrayerTimes: [[Prayer : Date]] = []
                    
                    let prayers = try month.select("thead th").compactMap({ Prayer(rawValue: try $0.text()) })
                    
                    let days = try month.select("tbody tr")
                    
                    for day in days {
                        var dayPrayerTimes: [Prayer : Date] = [:]
                        
                        let times = try day.select("td").map({ try $0.text() })
                        
                        for (prayer, time) in zip(prayers, times) {
                            if let prayerTime = time.date(using: "HH:mm") {
                                dayPrayerTimes[prayer] = prayerTime
                            }
                        }
                        
                        monthPrayerTimes.append(dayPrayerTimes)
                    }
                    
                    prayerTimes.append(monthPrayerTimes)
                }
                
                DispatchQueue.main.async {
                    completion(prayerTimes)
                }
            } catch {
                print(error)
            }
        }
    }
    
    static func fetchPrayerTimesToday(completion: @escaping ([Prayer : Date]) -> Void) {
        PrayerTimeModel.fetchPrayerTimes { prayerTimes in
            completion(self.prayerTimes(on: Date(), from: prayerTimes))
        }
    }
    
    static func prayerTimes(on date: Date, from prayerTimes: [[[Prayer : Date]]]) -> [Prayer : Date] {
        guard Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) else { return [:] }
        
        let month = date.component(.month) - 1
        let day = date.component(.day) - 1
        
        guard prayerTimes.indices.contains(month) else { return [:] }
        let prayerTimesMonth = prayerTimes[month]
        
        guard prayerTimesMonth.indices.contains(day) else { return [:] }
        let prayerTimesDay = prayerTimesMonth[day]
        
        return prayerTimesDay
    }
}
