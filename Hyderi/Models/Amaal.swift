//
//  Amaal.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import Foundation

struct Amaal: Decodable, Identifiable, Ibadah {
    let id: Int
    let title: String
    let subtitle: String?
    let description: String
    let sections: [AmaalSection]
}

struct AmaalSection: Decodable, Identifiable {
    let id: Int
    let description: String
    let details: [AmaalSectionDetail]
}

struct AmaalSectionDetail: Decodable, Identifiable {
    let id: String
    let heading: String?
    let surahId: Int?
    let url: String?
    let body: [AmaalSectionDetailBody]
}

struct AmaalSectionDetailBody: Decodable, Identifiable {
    let id: String
    let text: String?
    let transliteration: String?
    let translation: String?
}
