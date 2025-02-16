//
//  ZiyaratView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct ZiyaratView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    let ziyarat: Ziyarat
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(Array(ziyarat.verses.enumerated()), id: \.offset) { index, verse in
                        Verse(verse: verse, lastVerse: index == ziyarat.verses.count - 1)
                    }
                }
                .multilineTextAlignment(.center)
                .padding()
                .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 50)
            }.onChange(of: audioPlayer.currentTime) {
                updateScrollPosition(with: proxy)
            }
        }
        .onAppear {
            initialisePlayer()
        }
        .onDisappear {
            if audioPlayer.currentTime == 0 {
                audioPlayer.forceAudioSlider = false
            }
            
            audioPlayer.canDismissAudioSlider = true
        }
        .navigationTitle(ziyarat.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            Toolbar(audioPlayer: audioPlayer, ziyarat: ziyarat)
        }
    }
    
    private func initialisePlayer() {
        audioPlayer.forceAudioSlider = true
        audioPlayer.canDismissAudioSlider = false
        
        if audioPlayer.activeAudioId != "ziyarat-\(ziyarat.id)" {
            audioPlayer.pause()
            
            guard let audio = ziyarat.audio, let ziyaratAudioUrl = Bundle.main.url(forResource: audio, withExtension: "m4a") else {
                audioPlayer.resetPlayer()
                
                return
            }
            
            audioPlayer.initialisePlayer(with: ziyaratAudioUrl, id: "ziyarat-\(ziyarat.id)", title: ziyarat.title, subtitle: ziyarat.subtitle)
        }
    }
    
    private func updateScrollPosition(with proxy: ScrollViewProxy) {
        guard ziyarat.audio != nil, audioPlayer.isPlaying, let nextVerseIndex = ziyarat.verses.firstIndex(where: { verse in
            return verse.audio == Int(audioPlayer.currentTime)
        }) else { return }
        
        withAnimation {
            proxy.scrollTo(nextVerseIndex, anchor: .top)
        }
    }
    
    private struct Verse: View {
        let verse: ZiyaratVerse
        
        let lastVerse: Bool
        
        var body: some View {
            IbadahVerseView(verse: verse)
            
            separator
        }
        
        @ViewBuilder
        private var separator: some View {
            if !lastVerse {
                if verse.gap {
                    Spacer()
                        .frame(height: 50)
                } else {
                    Divider()
                }
            }
        }
    }
    
    private struct Toolbar: ToolbarContent {
        @StateObject var audioPlayer: AudioPlayer
        
        let ziyarat: Ziyarat
        
        var body: some ToolbarContent {
            if ziyarat.audio != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        audioPlayer.playPause()
                    } label: {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundStyle(Color.primary)
                            .frame(width: 30, alignment: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    let ziyarat: Ziyarat? = nil
    
    if let ziyarat {
        ZiyaratView(ziyarat: ziyarat)
    }
}
