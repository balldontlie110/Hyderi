//
//  PrayerDay.swift
//  Hyderi
//
//  Created by Ali Earp on 1/21/25.
//

import Foundation
import CoreData

@objc(PrayerDay)
public class PrayerDay: NSManagedObject, Identifiable {
    @NSManaged public var date: Date
    
    @NSManaged public var fajr: Bool
    @NSManaged public var zuhr: Bool
    @NSManaged public var asr: Bool
    @NSManaged public var maghrib: Bool
    @NSManaged public var isha: Bool
    
    convenience init(context: NSManagedObjectContext, date: Date) {
        self.init(context: context)
        
        self.date = date
    }
    
    var prayers: [(key: String, value: Bool)] {
        return [
            "Fajr" : fajr,
            "Zuhr" : zuhr,
            "Asr" : asr,
            "Maghrib" : maghrib,
            "Isha" : isha
        ].sorted(by: { comparePrayers($0.key, $1.key) })
    }
    
    private let prayerNames = ["Fajr", "Zuhr", "Asr", "Maghrib", "Isha"]
    
    private func comparePrayers(_ prayer1: String, _ prayer2: String) -> Bool {
        if let index1 = prayerNames.firstIndex(of: prayer1), let index2 = prayerNames.firstIndex(of: prayer2) {
            return index1 < index2
        }
        
        return true
    }
}
