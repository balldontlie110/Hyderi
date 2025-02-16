//
//  Ziyarat.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import Foundation

struct Ziyarat: Decodable, Identifiable, Ibadah {
    let id: Int
    let title: String
    let subtitle: String?
    let verses: [ZiyaratVerse]
    let audio: String?
}

struct ZiyaratVerse: Decodable, Identifiable, IbadahVerse {
    let id: IbadahVerseID
    let text: String?
    let translation: String
    let transliteration: String?
    let gap: Bool
    let audio: Int?
}
