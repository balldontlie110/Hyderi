//
//  TranslationView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI
import WStack

struct TranslationView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @AppStorage("bookmarkSurah") private var bookmarkSurah: Int = 0
    @AppStorage("bookmarkVerse") private var bookmarkVerse: Int = 0
    
    let surah: Surah
    
    @Binding var scrollPosition: Int?
    
    let surahTitle: any View
    
    let wordByWord: Bool
    
    let playPauseVerseAudio: (SurahVerse, String) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                AnyView(surahTitle)
                
                ForEach(surah.verses) { verse in
                    let surahVerse = "\(surah.id):\(verse.id)"
                    
                    Verse(verse, surah.id, surahVerse, wordByWord, $bookmarkSurah, $bookmarkVerse, audioPlayer.activeAudioId, audioPlayer.isPlaying) {
                        playPauseVerseAudio(verse, surahVerse)
                    }
                    
                    if verse.id != surah.verses.count {
                        Divider()
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
        
        let surahId: Int
        let surahVerse: String
        
        let wordByWord: Bool
        
        @Binding var bookmarkSurah: Int
        @Binding var bookmarkVerse: Int
        
        let activeAudioId: String?
        let isPlaying: Bool
        
        let playPauseVerseAudio: () -> Void
        
        init(_ verse: SurahVerse, _ surahId: Int, _ surahVerse: String, _ wordByWord: Bool, _ bookmarkSurah: Binding<Int>, _ bookmarkVerse: Binding<Int>, _ activeAudioId: String?, _ isPlaying: Bool, _ playPauseVerseAudio: @escaping () -> Void) {
            self.verse = verse
            
            self.surahId = surahId
            self.surahVerse = surahVerse
            
            self.wordByWord = wordByWord
            
            self._bookmarkSurah = bookmarkSurah
            self._bookmarkVerse = bookmarkVerse
            
            self.activeAudioId = activeAudioId
            self.isPlaying = isPlaying
            
            self.playPauseVerseAudio = playPauseVerseAudio
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(spacing: 10) {
                        playPauseButton
                        
                        bookmarkButton
                        
                        newQuranNoteButton
                    }
                    .font(.title3)
                    .foregroundStyle(Color.primary)
                    .padding(.bottom, 5)
                    
                    Spacer()
                    
                    text
                }
                .multilineTextAlignment(.trailing)
                .lineSpacing(10)
                
                verseTranslation
            }.padding(.vertical)
        }
        
        private var playPauseButton: some View {
            Button {
                playPauseVerseAudio()
            } label: {
                Image(systemName: activeAudioId == surahVerse && isPlaying ? "pause.fill" : "play.fill")
            }
        }
        
        private var bookmarkButton: some View {
            Button {
                if bookmarkSurah == surahId && bookmarkVerse == verse.id {
                    bookmarkSurah = 0
                    bookmarkVerse = 0
                } else {
                    bookmarkSurah = surahId
                    bookmarkVerse = verse.id
                }
            } label: {
                Image(systemName: surahId == bookmarkSurah && verse.id == bookmarkVerse ? "bookmark.fill" : "bookmark")
            }
        }
        
        private var newQuranNoteButton: some View {
            NavigationLink {
                QuranNoteView(surahId: surahId, verseId: verse.id)
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(Color.yellow)
            }
        }
        
        @ViewBuilder
        private var text: some View {
            if wordByWord {
                wordByWordText
            } else {
                arabicVerseText + Text(" ") + arabicVerseNumber
            }
        }
        
        private var wordByWordText: some View {
            WStack(verse.words, spacing: 20, lineSpacing: 20) { word in
                VStack(alignment: .center, spacing: 10) {
                    Text(word.text)
                        .font(.system(size: 40, weight: .bold))
                    
                    if let translation = word.translation {
                        Text(translation.translation)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                }.multilineTextAlignment(.center)
            }
            .padding(.bottom, 10)
            .environment(\.layoutDirection, .rightToLeft)
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
        
        private var verseTranslation: some View {
            HStack(alignment: .top) {
                Text("\(verse.id).")
                
                if let translation = verse.translation {
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
        TranslationView(surah: surah, scrollPosition: .constant(nil), surahTitle: EmptyView(), wordByWord: false, playPauseVerseAudio: { _, _ in })
    }
}
