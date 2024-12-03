//
//  QuranModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import Foundation

class QuranModel: ObservableObject {
    @Published var quran: [Surah] = []
    
    init() {
        loadQuran()
    }
    
    private func loadQuran() {
        guard let quran = JSONDecoder().decode(from: "Quran", to: [Surah].self) else { return }
        
        self.quran = quran
    }
}
