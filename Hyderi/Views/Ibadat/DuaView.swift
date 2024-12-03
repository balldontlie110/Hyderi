//
//  DuaView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct DuaView: View {
    let dua: Dua
    
    var body: some View {
        Text(dua.title)
    }
}

#Preview {
    let dua: Dua? = nil
    
    if let dua {
        DuaView(dua: dua)
    }
}
