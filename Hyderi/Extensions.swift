//
//  Extensions.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI

extension View {
    func secondaryRoundedBackground(cornerRadius: CGFloat) -> some View {
        self
            .background {
                Color(.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
    }
    
    func singleLine(withAlignment alignment: TextAlignment) -> some View {
        self
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(alignment)
    }
}
