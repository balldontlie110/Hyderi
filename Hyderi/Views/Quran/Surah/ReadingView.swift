//
//  ReadingView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

struct ReadingView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    let surah: Surah
    
    @Binding var scrollPosition: Int?
    
    let surahTitle: any View
    
    let playPauseVerseAudio: (SurahVerse, String) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                AnyView(surahTitle)
                
                ForEach(surah.verses) { verse in
                    Verse(verse: verse)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .padding(.vertical, 5)
                        .onTapGesture(count: 2) {
                            let surahVerse = "\(surah.id):\(verse.id)"
                            
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            
                            playPauseVerseAudio(verse, surahVerse)
                        }
                }
            }
            .padding(10)
            .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
            .scrollTargetLayout()
        }.scrollPosition(id: $scrollPosition, anchor: .top)
    }
    
    private struct Verse: View {
        let verse: SurahVerse
        
        var body: some View {
            arabicVerseText + Text(" ") + arabicVerseNumber
        }
        
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
    }
}

#Preview {
    let surah: Surah? = nil
    
    if let surah {
        ReadingView(surah: surah, scrollPosition: .constant(nil), surahTitle: EmptyView(), playPauseVerseAudio: { _, _ in })
    }
}
