//
//  AmaalView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct AmaalView: View {
    let amaal: Amaal
    
    var body: some View {
        Text(amaal.title)
    }
}

#Preview {
    let amaal: Amaal? = nil
    
    if let amaal {
        AmaalView(amaal: amaal)
    }
}
