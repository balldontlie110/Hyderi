//
//  SocialsView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/8/24.
//

import SwiftUI

struct Social: Identifiable {
    var id: String { handle }
    
    let name: String
    let handle: String
    let url: String
    let image: String
}

struct SocialsView: View {
    @State private var sheetHeight: CGFloat = 0
    
    private let socials: [Social] = [
        Social(name: "Website", handle: "hyderi.org.uk", url: "https://hyderi.org.uk", image: "website"),
        Social(name: "YouTube", handle: "@hyderi", url: "https://www.youtube.com/@hyderi/live", image: "youtube"),
        Social(name: "Instagram", handle: "@hydericentre", url: "https://www.instagram.com/hydericentre/", image: "instagram"),
        Social(name: "X", handle: "@HyderiCentre", url: "https://x.com/hydericentre", image: "x"),
        Social(name: "Facebook", handle: "Hyderi IslamicCentre", url: "https://www.facebook.com/HyderiCentre", image: "facebook")
    ]
    
    var body: some View {
        LazyVStack(spacing: 15) {
            ForEach(socials) { social in
                if let url = URL(string: social.url) {
                    Link(destination: url) {
                        HStack(spacing: 15) {
                            Image(social.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            Text(social.name)
                                .foregroundStyle(Color.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Text(social.handle)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.trailing)
                        }.font(.system(.headline, weight: .bold))
                    }
                }
            }
        }
        .padding()
        .overlay {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size.height)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self) { newHeight in
            DispatchQueue.main.async {
                sheetHeight = newHeight
            }
        }
        .presentationDetents([.height(sheetHeight)])
    }
}

struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    SocialsView()
}
