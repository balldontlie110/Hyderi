//
//  Quran.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import Foundation

struct Surah: Decodable, Identifiable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let total_verses: Int
    let verses: [SurahVerse]
}

struct SurahVerse: Decodable, Identifiable {
    let id: Int
    let text: String
    let audio: String
    let translations: [VerseTranslation]
    let words: [VerseWord]
}

struct VerseTranslation: Decodable, Identifiable {
    let id: Int
    let translation: String
}

struct VerseWord: Decodable, Identifiable {
    let id: String
    let text: String
    let translations: [WordTranslation]
}

struct WordTranslation: Decodable, Identifiable {
    let id: String
    let translation: String
}
