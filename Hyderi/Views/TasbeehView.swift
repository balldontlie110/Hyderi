//
//  TasbeehView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

struct Dhikr: IbadahVerse {
    var id: IbadahVerseID { .int(count) }
    
    let text: String?
    let transliteration: String?
    let translation: String
    
    let count: Int
    
    static let dhikrs = [
        Dhikr(text: "ٱللَّٰهُ أَكْبَرُ", transliteration: "ALLAHUAKBAR", translation: "Allah is Greatest", count: 0),
        Dhikr(text: "ٱلْحَمْدُ لِلَّٰهِ", transliteration: "ALHUMDULILLAH", translation: "Praise be to Allah", count: 34),
        Dhikr(text: "سُبْحَانَ ٱللَّٰهِ", transliteration: "SUBHANALLAH", translation: "Glory be to Allah", count: 67)
    ]
}

struct TasbeehView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @State private var count: Int = 0
    
    var body: some View {
        ZStack {
            Button {
                incrementCount()
            } label: {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack(spacing: 50) {
                Spacer()
                
                dhikrButton
                
                dhikr
                
                Spacer()
                
                HStack {
                    minusButton
                    
                    Spacer()
                    
                    resetButton
                }
            }.padding()
        }
        .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
        .navigationTitle("Tasbeeh")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }
    
    private var dhikrButton: some View {
        Button {
            incrementCount()
        } label: {
            VStack(spacing: 15) {
                currentCount
                
                totalCount
            }
            .frame(width: 150, height: 150)
            .background(Color(.secondarySystemBackground))
            .clipShape(Circle())
        }
    }
    
    private func incrementCount() {
        withAnimation(nil) {
            count += 1
            
            if count == 34 || count == 67 || count == 100 {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
            if count >= 100 {
                count = 0
            }
        }
    }
    
    private var currentCount: some View {
        Text(String(currentDhikrCount))
            .font(.system(size: 45, weight: .bold, design: .rounded))
            .foregroundStyle(Color.primary)
    }
    
    private var currentDhikrCount: Int {
        if count < 34 {
            return count
        } else if count < 67 {
            return count - 34
        } else {
            return count - 67
        }
    }
    
    private var totalCount: some View {
        Text(String(count))
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(Color.secondary)
    }
    
    @ViewBuilder
    private var dhikr: some View {
        if let dhikr = Dhikr.dhikrs.last(where: { count >= $0.count }) {
            IbadahVerseView(verse: dhikr)
        }
    }
    
    private var minusButton: some View {
        Button {
            if count > 0 {
                withAnimation(nil) {
                    count -= 1
                }
            }
        } label: {
            HStack {
                Image(systemName: "minus.circle")
                
                Text("Minus 1")
            }
            .foregroundStyle(Color.primary)
            .frame(maxWidth: .infinity)
        }.buttonStyle(AdjustCountButtonStyle())
    }
    
    private var resetButton: some View {
        Button(role: .destructive) {
            withAnimation(nil) {
                count = 0
            }
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise.circle")
                
                Text("Reset")
            }
            .foregroundStyle(Color.red)
            .frame(maxWidth: .infinity)
        }.buttonStyle(AdjustCountButtonStyle())
    }
    
    private struct AdjustCountButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(.headline, weight: .bold))
                .padding()
                .secondaryRoundedBackground(cornerRadius: 15)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TasbeehView()
}
