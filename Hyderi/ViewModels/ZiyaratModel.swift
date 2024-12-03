//
//  ZiyaratModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import Foundation

class ZiyaratModel: ObservableObject {
    @Published var ziaraah: [Ziyarat] = []
    
    init() {
        loadZiaraah()
    }
    
    private func loadZiaraah() {
        guard let ziaraah = JSONDecoder().decode(from: "Ziaraah", to: [Ziyarat].self) else { return }
        
        self.ziaraah = ziaraah
    }
}
