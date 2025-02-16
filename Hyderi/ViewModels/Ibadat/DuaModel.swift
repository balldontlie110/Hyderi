//
//  DuaModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import Foundation

class DuaModel: ObservableObject {
    @Published var duas: [Dua] = []
    
    init() {
        loadDuas()
    }
    
    private func loadDuas() {
        guard let duas = JSONDecoder.decode(from: "Duas", to: [Dua].self) else { return }
        
        self.duas = duas
    }
}
