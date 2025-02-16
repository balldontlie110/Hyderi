//
//  QuranNote.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import SwiftUI
import CoreData
import CoreTransferable

@objc(QuranNote)
public class QuranNote: NSManagedObject, Codable, Identifiable {
    @NSManaged public var title: String
    @NSManaged public var note: String
    
    @NSManaged public var surahId: Int64
    @NSManaged public var verseIds: [Int]
    
    @NSManaged public var dateCreated: Date
    @NSManaged public var dateModified: Date
    
    @NSManaged public var folder: QuranNotesFolder?
    
    enum CodingKeys: String, CodingKey {
        case title
        case note
        case surahId
        case verseIds
        case dateCreated
        case dateModified
        case folder
    }
    
    public required convenience init(from decoder: any Decoder) throws {
        let context = CoreDataManager.shared.container.viewContext
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.note = try container.decode(String.self, forKey: .note)
        self.surahId = try container.decode(Int64.self, forKey: .surahId)
        self.verseIds = try container.decode([Int].self, forKey: .verseIds)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        self.folder = try container.decodeIfPresent(QuranNotesFolder.self, forKey: .folder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(note, forKey: .note)
        try container.encode(surahId, forKey: .surahId)
        try container.encode(verseIds, forKey: .verseIds)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateModified, forKey: .dateModified)
    }
}

extension QuranNote {
    convenience init(context: NSManagedObjectContext, title: String, note: String, surahId: Int, verseIds: [Int], dateCreated: Date, dateModified: Date, folder: QuranNotesFolder?) {
        self.init(context: context)
        
        self.title = title
        self.note = note
        
        self.surahId = Int64(surahId)
        self.verseIds = verseIds
        
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        
        self.folder = folder
    }
    
    convenience init(context: NSManagedObjectContext, from oldQuranNote: QuranNote, folder: QuranNotesFolder) {
        self.init(context: context)
        
        self.title = oldQuranNote.title
        self.note = oldQuranNote.note
        
        self.surahId = oldQuranNote.surahId
        self.verseIds = oldQuranNote.verseIds
        
        self.dateCreated = oldQuranNote.dateCreated
        self.dateModified = Date()
        
        self.folder = folder
    }
}
