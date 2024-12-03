//
//  TranslationView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

struct TranslationView: View {
    let surah: Surah
    
    @Binding var scrollPosition: Int?
    
    let surahTitle: any View
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 25) {
                AnyView(surahTitle)
                
                ForEach(Array(surah.verses.enumerated()), id: \.offset) { index, verse in
                    Verse(verse: verse)
                    
                    if index != surah.verses.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(10)
            .scrollTargetLayout()
        }.scrollPosition(id: $scrollPosition, anchor: .top)
    }
    
    struct Verse: View {
        let verse: SurahVerse
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack {
                        playButton
                    }
                    
                    Spacer()
                    
                    arabicVerseText + Text(" ") + arabicVerseNumber
                }
                .multilineTextAlignment(.trailing)
                .lineSpacing(10)
                
                verseTranslation
            }
        }
        
        private var playButton: some View {
            Button {
                
            } label: {
                Image(systemName: "play.fill")
                    .font(.headline)
            }
        }
        
        @ViewBuilder
        private var arabicVerseText: Text {
            Text(verse.text)
                .font(.system(size: 40, weight: .bold))
        }
        
        @ViewBuilder
        private var arabicVerseNumber: Text {
            let arabicNumerals = ["٠" ,"١" ,"٢" ,"٣" ,"٤" ,"٥" ,"٦" ,"٧" ,"٨" ,"٩"]
            
            let arabicNumber = String(verse.id).map { number in
                if let index = Int(String(number)) {
                    return arabicNumerals[index]
                }
                
                return ""
            }.joined()
            
            Text(arabicNumber)
                .font(Font.custom("KFGQPCUthmanicScriptHAFS", size: 40))
        }
        
        private var verseTranslation: some View {
            HStack(alignment: .top) {
                Text("\(verse.id).")
                
                if let translation = verse.translations.first {
                    Text(translation.translation)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

#Preview {
    let surah: Surah? = nil
    
    if let surah {
        TranslationView(surah: surah, scrollPosition: .constant(nil), surahTitle: EmptyView())
    }
}
