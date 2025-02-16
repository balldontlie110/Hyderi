//
//  AudioPlayer.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var forceAudioSlider: Bool = false
    @Published var canDismissAudioSlider: Bool = true
    @Published var tabView: Bool = false
    
    @Published var activeAudioId: String?
    
    @Published var player: AVAudioPlayer?
    
    private var displayLink: CADisplayLink?
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    @Published var title: String = ""
    @Published var subtitle: String?
    
    @Published var nextVerseAction: (() -> Void)?
    
    @AppStorage("continueAudio") var continueAudio: Bool = false
    
    @Published var selectedNasheedAudioId: Int?
    @AppStorage("repeatNasheed") var repeatNasheed: Bool = false
    
    @Published var ibadahType: IbadatView.IbadahType?
    @Published var ibadahId: Int?
    @Published var playNextIbadah: (() -> Void)?
    
    private var playTarget: Any?
    private var pauseTarget: Any?
    private var changePlaybackPositionTarget: Any?
    private var previousVerseTarget: Any?
    private var nextVerseTarget: Any?
    
    func initialisePlayer(with audioUrl: URL?, id: String, title: String, subtitle: String? = nil, forceInitialise: Bool = true, isNasheed: Bool = false, previousVerseAction: (() -> Void)? = nil, nextVerseAction: (() -> Void)? = nil, playNextIbadah: (() -> Void)? = nil) {
        guard let audioUrl else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: audioUrl)
            player?.delegate = self
            
            currentTime = 0
            duration = player?.duration ?? 0
            
            self.title = title
            self.subtitle = subtitle
            
            if !isNasheed {
                self.selectedNasheedAudioId = nil
            }
            
            self.nextVerseAction = nextVerseAction
            
            self.playNextIbadah = playNextIbadah
            
            setRemoteCommands(previousVerseAction, nextVerseAction)
            setNowPlayingInfo()
            
            self.activeAudioId = id
        } catch {
            print(error)
        }
    }
    
    func startDisplayLink() {
        stopDisplayLink()
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateCurrentTime))
        self.displayLink?.add(to: .current, forMode: .common)
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateCurrentTime() {
        guard let player else { return }
        
        self.currentTime = player.currentTime
    }
    
    private func setNowPlayingInfo() {
        var nowPlayingInfo: [String : Any] = [:]
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = subtitle
        
        if let image = UIImage(named: "hyderi") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300), requestHandler: { _ in
                image
            })
        }
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setRemoteCommands(_ previousVerseAction: (() -> Void)?, _ nextVerseAction: (() -> Void)?) {
        let commands = MPRemoteCommandCenter.shared()
        
        commands.playCommand.removeTarget(playTarget)
        commands.pauseCommand.removeTarget(pauseTarget)
        commands.changePlaybackPositionCommand.removeTarget(changePlaybackPositionTarget)
        commands.previousTrackCommand.removeTarget(previousVerseTarget)
        commands.nextTrackCommand.removeTarget(nextVerseTarget)
        
        playTarget = commands.playCommand.addTarget { _ in
            self.play()
            
            return .success
        }
        
        pauseTarget = commands.pauseCommand.addTarget { _ in
            self.pause()
            
            return .success
        }
        
        changePlaybackPositionTarget = commands.changePlaybackPositionCommand.addTarget { commandEvent in
            guard let event = commandEvent as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            self.player?.currentTime = event.positionTime
            self.currentTime = event.positionTime
            
            self.updateNowPlayingInfo()
            
            return .success
        }
        
        if let previousVerseAction {
            previousVerseTarget = commands.previousTrackCommand.addTarget { _ in
                previousVerseAction()
                
                return .success
            }
        }
        
        if let nextVerseAction {
            nextVerseTarget = commands.nextTrackCommand.addTarget { _ in
                nextVerseAction()
                
                return .success
            }
        }
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        player?.play()
        
        startDisplayLink()
        
        DispatchQueue.main.async {
            self.updateNowPlayingInfo()
        }
        
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        
        stopDisplayLink()
        
        DispatchQueue.main.async {
            self.updateNowPlayingInfo()
        }
        
        isPlaying = false
    }
    
    func updateNowPlayingInfo() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo
        
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        
        if continueAudio {
            nextVerseAction?()
        }
        
        if selectedNasheedAudioId != nil && repeatNasheed {
            setNowPlayingInfo()
            play()
        }
        
        playNextIbadah?()
    }
    
    func resetPlayer() {
        forceAudioSlider = false
        
        activeAudioId = nil
        
        player = nil
        
        isPlaying = false
        currentTime = 0
        duration = 0
        
        title = ""
        subtitle = nil
    }
}
