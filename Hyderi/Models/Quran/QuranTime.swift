//
//  QuranTime.swift
//  Hyderi
//
//  Created by Ali Earp on 12/21/24.
//

import Foundation
import CoreData

@objc(QuranTime)
public class QuranTime: NSManagedObject, Identifiable {
    @NSManaged public var date: Date
    
    @NSManaged public var time: Int64
    
    convenience init(context: NSManagedObjectContext, date: Date, time: Int64) {
        self.init(context: context)
        
        self.date = date
        self.time = time
    }
    
    convenience init(date: Date, time: Int64) {
        self.init(entity: QuranTime.entity(), insertInto: nil)
        
        self.date = date
        self.time = time
    }
}
