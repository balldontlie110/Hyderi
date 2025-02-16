//
//  DuaView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct DuaView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    let dua: Dua
    
    @State private var scrollPosition: IbadahVerseID?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(dua.verses) { verse in
                    Verse(verse: verse, lastVerse: verse.id.intValue == dua.verses.count)
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            .safeAreaPadding(.bottom, 50)
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition, anchor: .top)
        .onChange(of: audioPlayer.currentTime) {
            updateScrollPosition()
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
        .onChange(of: scenePhase) {
            handleScenePhaseChange()
        }
        .navigationTitle(dua.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            Toolbar(audioPlayer: audioPlayer, dua: dua)
        }
    }
    
    private func initialisePlayer() {
        audioPlayer.forceAudioSlider = true
        audioPlayer.canDismissAudioSlider = false
        
        if audioPlayer.activeAudioId != "dua-\(dua.id)" {
            audioPlayer.pause()
            
            guard let audio = dua.audio, let duaAudioUrl = Bundle.main.url(forResource: audio, withExtension: "m4a") else {
                audioPlayer.resetPlayer()
                
                return
            }
            
            audioPlayer.initialisePlayer(with: duaAudioUrl, id: "dua-\(dua.id)", title: dua.title, subtitle: dua.subtitle)
        }
    }
    
    private func updateScrollPosition() {
        DispatchQueue.global(qos: .background).async {
            guard dua.audio != nil, audioPlayer.isPlaying, let nextVerseId = dua.verses.first(where: { verse in
                return verse.audio == Int(audioPlayer.currentTime)
            })?.id, nextVerseId != scrollPosition else { return }
            
            DispatchQueue.main.async {
                withAnimation {
                    scrollPosition = nextVerseId
                }
            }
        }
    }
    
    private func handleScenePhaseChange() {
        switch scenePhase {
        case .active:
            audioPlayer.startDisplayLink()
        case .inactive:
            audioPlayer.stopDisplayLink()
        case .background:
            audioPlayer.stopDisplayLink()
        @unknown default:
            return
        }
    }
    
    private struct Verse: View {
        let verse: DuaVerse
        
        let lastVerse: Bool
        
        var body: some View {
            IbadahVerseView(verse: verse)
            
            separator
        }
        
        @ViewBuilder
        private var separator: some View {
            if !lastVerse {
                Divider()
            }
        }
    }
    
    private struct Toolbar: ToolbarContent {
        @StateObject var audioPlayer: AudioPlayer
        
        let dua: Dua
        
        var body: some ToolbarContent {
            if dua.audio != nil {
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
    let dua: Dua? = nil
    
    if let dua {
        DuaView(dua: dua)
    }
}
