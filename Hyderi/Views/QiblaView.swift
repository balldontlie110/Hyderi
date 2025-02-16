//
//  QiblaView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

struct QiblaView: View {
    @StateObject private var qiblaModel: QiblaModel = QiblaModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            if let heading = qiblaModel.qiblaHeading() {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(heading < 2.5 && heading > -2.5 ? Color.green : Color.secondary)
                    .frame(width: 100, height: 100)
                    .animation(.easeInOut, value: heading)
                    .onChange(of: heading) { oldValue, newValue in
                        if !(oldValue < 2.5 && oldValue > -2.5) && (newValue < 2.5 && newValue > -2.5) {
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        }
                    }
                
                Spacer()
                
                Image(systemName: "location.north")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(arrowColor(for: heading))
                    .frame(width: 100, height: 100)
                    .rotationEffect(Angle(degrees: heading))
                    .animation(.easeInOut, value: heading)
            } else {
                ProgressView()
            }
            
            Spacer()
        }
        .navigationTitle("Qibla")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }
    
    private func arrowColor(for heading: Double) -> Color {
        let increment = 410.0 / 180.0
        
        let close = heading.magnitude * increment < 205
        
        let red = close ? 255 - ((180 - heading.magnitude) * increment - 205) : 255
        let green = close ? 255 : (180 - heading.magnitude) * increment + 50
        
        return Color(red: red / 255, green: green / 255, blue: 0)
    }
}

#Preview {
    QiblaView()
}
