//
//  IbadahVerseView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/9/24.
//

import SwiftUI

struct IbadahVerseView: View {
    let verse: IbadahVerse
    
    var body: some View {
        VStack(spacing: 15) {
            arabicVerseText
            
            verseTransliteration
            
            verseTranslation
        }.padding(.vertical)
    }
    
    @ViewBuilder
    private var arabicVerseText: some View {
        if let text = verse.text {
            Text(text)
                .font(.system(size: 40, weight: .bold))
                .lineSpacing(10)
        }
    }
    
    @ViewBuilder
    private var verseTransliteration: some View {
        if let transliteration = verse.transliteration {
            Text(transliteration.uppercased())
                .font(.system(size: 20))
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var verseTranslation: some View {
        Text(verse.translation)
            .font(.system(size: 20))
    }
}

#Preview {
    let duaVerse: IbadahVerse? = nil
    
    if let duaVerse {
        IbadahVerseView(verse: duaVerse)
    }
}
