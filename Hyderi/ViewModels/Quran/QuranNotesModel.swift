//
//  QuranNotesModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/24/24.
//

import SwiftUI

class QuranNotesModel: ObservableObject {
    @Published var folder: QuranNotesFolder?
    @Published var note: QuranNote?
}
