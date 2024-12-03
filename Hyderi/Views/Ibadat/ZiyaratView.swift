//
//  ZiyaratView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct ZiyaratView: View {
    let ziyarat: Ziyarat
    
    var body: some View {
        Text(ziyarat.title)
    }
}

#Preview {
    let ziyarat: Ziyarat? = nil
    
    if let ziyarat {
        ZiyaratView(ziyarat: ziyarat)
    }
}
