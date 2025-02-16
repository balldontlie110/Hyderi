//
//  NasheedView.swift
//  Hyderi
//
//  Created by Ali Earp on 1/26/25.
//

import SwiftUI

struct NasheedView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    let nasheed: Nasheed
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(nasheed.verses) { verse in
                    Verse(verse: verse, lastVerse: verse.id.intValue == nasheed.verses.count)
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            .safeAreaPadding(.bottom, 50)
            .scrollTargetLayout()
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
        .onChange(of: audioPlayer.selectedNasheedAudioId) {
            audioPlayer.pause()
            
            initialisePlayer(forceInitialise: true)
        }
        .onChange(of: scenePhase) {
            handleScenePhaseChange()
        }
        .navigationTitle(nasheed.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            Toolbar(audioPlayer: audioPlayer, nasheed: nasheed)
        }
    }
    
    private func initialisePlayer(forceInitialise: Bool = false) {
        audioPlayer.forceAudioSlider = true
        audioPlayer.canDismissAudioSlider = false
        
        if audioPlayer.activeAudioId != "nasheed-\(nasheed.id)" || forceInitialise {
            audioPlayer.pause()
            
            if !forceInitialise {
                audioPlayer.selectedNasheedAudioId = nasheed.audios.first?.id
            }
            
            guard let audio = nasheed.audios.first(where: { $0.id == audioPlayer.selectedNasheedAudioId }), let nasheedAudioUrl = Bundle.main.url(forResource: audio.audio, withExtension: "m4a") else {
                audioPlayer.resetPlayer()
                
                return
            }
            
            audioPlayer.initialisePlayer(with: nasheedAudioUrl, id: "nasheed-\(nasheed.id)", title: "\(nasheed.title) - \(audio.title)", subtitle: nasheed.subtitle, isNasheed: true)
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
        let verse: NasheedVerse
        
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
        
        let nasheed: Nasheed
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(nasheed.audios) { audio in
                        Button {
                            audioPlayer.selectedNasheedAudioId = audio.id
                        } label: {
                            HStack {
                                Text(audio.title)
                                
                                if audio.id == audioPlayer.selectedNasheedAudioId {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(Color.primary)
                        .frame(width: 30, alignment: .center)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    audioPlayer.repeatNasheed.toggle()
                } label: {
                    Image(systemName: "repeat")
                        .foregroundStyle(audioPlayer.repeatNasheed ? Color.accentColor : Color.secondary)
                        .frame(width: 30, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    let nasheed: Nasheed? = nil
    
    if let nasheed {
        NasheedView(nasheed: nasheed)
    }
}
