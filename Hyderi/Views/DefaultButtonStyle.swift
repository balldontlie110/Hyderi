//
//  DefaultButtonStyle.swift
//  Hyderi
//
//  Created by Ali Earp on 12/7/24.
//

import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            
            configuration.label
                .font(.system(.headline, weight: .bold))
                .foregroundStyle(Color.white)
            
            Spacer()
        }
        .padding()
        .background {
            Color.accentColor
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
