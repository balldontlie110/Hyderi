//
//  Quran.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

struct Surah: Decodable, Identifiable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let totalVerses: Int
    var verses: [SurahVerse]
}

struct SurahVerse: Decodable, Identifiable {
    @AppStorage("translatorId") private var translatorId = 0
    
    let id: Int
    let text: String
    let audio: String
    
    var words: [VerseWord]
    
    private enum CodingKeys: String, CodingKey {
        case id, text, audio, words
    }
    
    var translations: [VerseTranslation] = []
    
    var translation: VerseTranslation? {
        return translations.first(where: { $0.id == translatorId }) ?? translations.first
    }
}

struct VerseTranslation: Decodable, Identifiable {
    let id: Int
    let translation: String
}

struct VerseWord: Decodable, Identifiable {
    @AppStorage("wordByWordLanguageCode") private var wordByWordLanguageCode = ""
    
    let id: String
    let text: String
    
    private enum CodingKeys: String, CodingKey {
        case id, text
    }
    
    var translations: [WordTranslation] = []
    
    var translation: WordTranslation? {
        return translations.first(where: { $0.id == wordByWordLanguageCode }) ?? translations.first
    }
}

struct WordTranslation: Decodable, Identifiable {
    let id: String
    let translation: String
}
