//
//  QuranNotesFolder.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import Foundation
import CoreData

@objc(QuranNotesFolder)
public class QuranNotesFolder: NSManagedObject, Codable, Identifiable {
    @NSManaged public var title: String
    
    @NSManaged public var dateCreated: Date
    @NSManaged public var dateModified: Date
    
    @NSManaged public var quranNotes: Set<QuranNote>
    
    enum CodingKeys: String, CodingKey {
        case title
        case dateCreated
        case dateModified
        case quranNotes
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let context = CoreDataManager.shared.container.viewContext

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decode(String.self, forKey: .title)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        self.quranNotes = try container.decode(Set<QuranNote>.self, forKey: .quranNotes)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateModified, forKey: .dateModified)
        try container.encode(quranNotes, forKey: .quranNotes)
    }
}

extension QuranNotesFolder {
    convenience init(context: NSManagedObjectContext, title: String, dateCreated: Date, dateModified: Date, quranNotes: Set<QuranNote>) {
        self.init(context: context)
        
        self.title = title
        
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        
        self.quranNotes = quranNotes
    }
}
