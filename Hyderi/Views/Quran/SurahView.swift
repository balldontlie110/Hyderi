//
//  SurahView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

struct SurahView: View {
    let surah: Surah
    
    @State private var selectedTab: SelectedTab = .translation
    
    private enum SelectedTab {
        case translation, reading
    }
    
    @State private var scrollPosition: Int?
    
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Translation", systemImage: "book.closed", value: .translation) {
                TranslationView(surah: surah, scrollPosition: $scrollPosition, surahTitle: surahTitle)
            }
            
            Tab("Reading", systemImage: "book", value: .reading) {
                ReadingView(surah: surah, scrollPosition: $scrollPosition, surahTitle: surahTitle)
            }
        }
        .onChange(of: selectedTab) { _, _ in
            maintainScrollPosition()
        }
        .onRotate {
            maintainScrollPosition()
        }
        .navigationTitle(surah.transliteration)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }
    
    private var surahTitle: some View {
        VStack {
            Text(surah.name)
                .font(.system(size: 50, weight: .bold))
            
            Text(surah.translation)
                .font(.system(.callout, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }.padding(.vertical, 10)
    }
    
    private func maintainScrollPosition() {
        let scrollPosition = self.scrollPosition
        self.scrollPosition = nil
        
        Task { @MainActor in
            self.scrollPosition = scrollPosition
        }
    }
}

#Preview {
    let surah: Surah? = nil
    
    if let surah {
        SurahView(surah: surah)
    }
}
