//
//  QuranView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI

struct QuranView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @EnvironmentObject private var quranModel: QuranModel
    
    @AppStorage("bookmarkSurah") private var bookmarkSurah: Int = 0
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(quranModel.filteredQuran) { surah in
                    NavigationLink {
                        SurahView(surah: surah)
                    } label: {
                        SurahCard(surah: surah)
                    }
                }
                
                ForEach(quranModel.filteredVerses, id: \.id) { _, surah, verseId in
                    NavigationLink {
                        SurahView(surah: surah, scrollPosition: verseId)
                    } label: {
                        SurahCard(surah: surah, verseId: verseId)
                    }
                }
                
                if let surahAndVerse = quranModel.surahAndVerse {
                    NavigationLink {
                        SurahView(surah: surahAndVerse.surah, scrollPosition: surahAndVerse.verseId)
                    } label: {
                        SurahCard(surah: surahAndVerse.surah, verseId: surahAndVerse.verseId)
                    }
                }
            }
            .padding(10)
            .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
        }
        .searchable(text: $quranModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Quran")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            Toolbar(bookmark: bookmark)
        }
    }
    
    private var bookmark: Surah? {
        quranModel.quran.first(where: { $0.id == bookmarkSurah })
    }
    
    private struct SurahCard: View {
        let surah: Surah
        
        let verseId: Int?
        
        init(surah: Surah, verseId: Int? = nil) {
            self.surah = surah
            self.verseId = verseId
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    surahNumber
                    
                    surahName
                    
                    Spacer()
                    
                    surahInfo
                }
                
                verseTranslation
            }
            .foregroundStyle(Color.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding([.vertical, .trailing], 15)
            .padding(.leading, 10)
            .secondaryRoundedBackground(cornerRadius: 5)
        }
        
        private var surahNumber: some View {
            ZStack {
                Image(systemName: "diamond")
                    .font(.system(size: 40, weight: .ultraLight))
                
                Text(String(surah.id))
                    .font(.headline)
            }
        }
        
        private var surahName: some View {
            VStack(alignment: .leading) {
                Text(surah.transliteration)
                    .font(.system(.headline, weight: .bold))
                
                Text(surah.translation)
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        
        private var surahInfo: some View {
            VStack(alignment: .trailing) {
                Text(surah.name)
                    .font(.system(.headline, weight: .bold))
                
                Text("\(surah.totalVerses) Ayahs")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        
        @ViewBuilder
        private var verseTranslation: some View {
            if let verse = surah.verses.first(where: { $0.id == verseId }), let translation = verse.translation {
                HStack(alignment: .top) {
                    Text("\(verse.id).")
                    
                    Text(translation.translation)
                        .multilineTextAlignment(.leading)
                }
                .font(.subheadline)
                .lineLimit(nil)
            }
        }
    }
    
    private struct Toolbar: ToolbarContent {
        @AppStorage("bookmarkVerse") private var bookmarkVerse: Int = 0
        
        let bookmark: Surah?
        
        var body: some ToolbarContent {
            if let bookmark {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SurahView(surah: bookmark, scrollPosition: bookmarkVerse)
                    } label: {
                        Image(systemName: "bookmark")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    QuranNotesFoldersView()
                } label: {
                    Image(systemName: "note.text")
                        .foregroundStyle(Color.yellow)
                }
            }
        }
    }
}

#Preview {
    QuranView()
}
