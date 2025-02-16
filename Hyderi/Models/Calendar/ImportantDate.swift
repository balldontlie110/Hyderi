//
//  ImportantDate.swift
//  Hyderi
//
//  Created by Ali Earp on 12/29/24.
//

import Foundation

struct ImportantDate: Decodable, Identifiable, Equatable {
    let id: Int
    let day: Int
    let month: Int
    let title: String
    let subtitle: String?
    let year: Int?
    let yearType: String?
}
