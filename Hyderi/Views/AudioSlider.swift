//
//  AudioSlider.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct AudioSlider: View {
    @StateObject var audioPlayer: AudioPlayer
    
    @State private var audioSliderValue: Double = 0
    
    var body: some View {
        if audioPlayer.forceAudioSlider {
            HStack {
                playPauseButton
                
                currentTime
                
                slider
                
                duration
            }
            .padding(10)
            .secondaryRoundedBackground(cornerRadius: 15)
            .if(audioPlayer.canDismissAudioSlider) { view in
                view
                    .contextMenu {
                        Button {
                            audioPlayer.resetPlayer()
                        } label: {
                            HStack {
                                Text("Stop Playing")
                                
                                Image(systemName: "stop.circle")
                            }.font(.system(.headline, weight: .semibold))
                        }
                    }
            }
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .safeAreaPadding(.bottom, audioPlayer.tabView ? 50 : 0)
            .animation(.default, value: audioPlayer.tabView)
        }
    }
    
    private func updatePlayer() {
        guard let player = audioPlayer.player, audioPlayer.isPlaying else { return }
        
        audioPlayer.currentTime = player.currentTime
    }
    
    private var playPauseButton: some View {
        Button {
            audioPlayer.playPause()
        } label: {
            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                .font(.title3)
                .foregroundStyle(!audioPlayer.forceAudioSlider ? Color.secondary : Color.primary)
                .padding(.horizontal, 5)
        }.disabled(!audioPlayer.forceAudioSlider)
    }
    
    private var currentTime: some View {
        Text(formatTime(from: audioPlayer.currentTime))
            .monospacedDigit()
    }
    
    private var slider: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundStyle(Color.secondary)
                    .frame(width: proxy.size.width)
                
                if audioPlayer.currentTime > 0 && audioPlayer.currentTime < audioPlayer.duration {
                    Capsule()
                        .foregroundStyle(Color.primary)
                        .frame(width: proxy.size.width * (audioPlayer.currentTime / audioPlayer.duration))
                }
            }
            .clipShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newCurrentTime = min(max(0, value.location.x / proxy.size.width * audioPlayer.duration), audioPlayer.duration)
                        
                        audioPlayer.player?.currentTime = newCurrentTime
                        audioPlayer.currentTime = newCurrentTime
                        
                        audioPlayer.updateNowPlayingInfo()
                    }
            )
        }.frame(height: 10)
    }
    
    private var duration: some View {
        Text(formatTime(from: audioPlayer.duration))
            .monospacedDigit()
    }
    
    private func formatTime(from time: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        
        return formatter.string(from: time) ?? ""
    }
}

#Preview {
    AudioSlider(audioPlayer: AudioPlayer())
}
