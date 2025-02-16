//
//  Reciter.swift
//  Hyderi
//
//  Created by Ali Earp on 12/6/24.
//

import Foundation

struct Reciter: Decodable, Identifiable {
    let id: Int
    let url: String
    let localAsset: String
    let fullName: String
    let name: String
}
