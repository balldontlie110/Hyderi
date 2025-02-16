//
//  Nasheed.swift
//  Hyderi
//
//  Created by Ali Earp on 1/26/25.
//

import Foundation

struct Nasheed: Decodable, Identifiable, Ibadah {
    let id: Int
    let title: String
    let subtitle: String?
    let verses: [NasheedVerse]
    let audios: [NasheedAudio]
}

struct NasheedVerse: Decodable, Identifiable, IbadahVerse {
    let id: IbadahVerseID
    let text: String?
    let translation: String
    let transliteration: String?
    let audio: Int?
}

struct NasheedAudio: Decodable, Identifiable {
    let id: Int
    let title: String
    let audio: String
}
