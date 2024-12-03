//
//  AmaalModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import Foundation

class AmaalModel: ObservableObject {
    @Published var amaals: [Amaal] = []
    
    init() {
        loadAmaals()
    }
    
    private func loadAmaals() {
        guard let amaals = JSONDecoder().decode(from: "Amaals", to: [Amaal].self) else { return }
        
        self.amaals = amaals
    }
}
