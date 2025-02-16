//
//  Translator.swift
//  Hyderi
//
//  Created by Ali Earp on 12/14/24.
//

import Foundation

struct Translator: Decodable, Identifiable {
    let id: Int
    let name: String
    let language: String
    let languageCode: String
}

struct Translation: Decodable {
    let translations: [TranslationVerse]
}

struct TranslationVerse: Decodable {
    let text: String
}
