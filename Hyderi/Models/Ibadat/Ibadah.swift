//
//  Ibadah.swift
//  Hyderi
//
//  Created by Ali Earp on 12/9/24.
//

import Foundation

protocol Ibadah {
    var id: Int { get }
    var title: String { get }
    var subtitle: String? { get }
}

protocol IbadahVerse {
    var id: IbadahVerseID { get }
    var text: String? { get }
    var translation: String { get }
    var transliteration: String? { get }
}

enum IbadahVerseID: Decodable, Hashable {
    case string(String)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(IbadahVerseID.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected to decode String or Int but found another type instead."
            ))
        }
    }
    
    var intValue: Int? {
        switch self {
        case .string:
            return nil
        case .int(let int):
            return int
        }
    }
}
