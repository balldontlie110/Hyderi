//
//  NasheedModel.swift
//  Hyderi
//
//  Created by Ali Earp on 1/26/25.
//

import Foundation

class NasheedModel: ObservableObject {
    @Published var nasheeds: [Nasheed] = []
    
    init() {
        loadNasheeds()
    }
    
    private func loadNasheeds() {
        guard let nasheeds = JSONDecoder.decode(from: "Nasheeds", to: [Nasheed].self) else { return }
        
        self.nasheeds = nasheeds
    }
}
