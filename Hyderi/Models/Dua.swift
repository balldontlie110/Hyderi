//
//  Dua.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import Foundation

struct Dua: Decodable, Identifiable, Ibadah {
    let id: Int
    let title: String
    let subtitle: String?
    let verses: [DuaVerse]
    let audio: String?
}

struct DuaVerse: Decodable, Identifiable {
    let id: Int
    let text: String
    let translation: String
    let transliteration: String
    let audio: Int?
}
