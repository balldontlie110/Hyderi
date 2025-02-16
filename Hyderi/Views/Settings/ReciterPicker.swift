//
//  ReciterPicker.swift
//  Hyderi
//
//  Created by Ali Earp on 12/6/24.
//

import SwiftUI
import WStack
import AVFoundation

struct ReciterPicker: View {
    @StateObject var reciterModel: ReciterModel
    
    @Binding var showReciterPicker: Bool
    
    @State private var selectedReciterId: Int?
    @State private var downloading: Bool = false
    
    @State private var player: AVPlayer?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    Text("Choose a reciter")
                        .font(.system(.title, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    WStack(reciterModel.reciters, alignment: .center, spacing: 25, lineSpacing: 20) { reciter in
                        reciterCard(for: reciter)
                    }.disabled(downloading)
                    
                    downloadBar
                    
                    continueButton
                }
                .padding(10)
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            .interactiveDismissDisabled(downloading)
            .onChange(of: reciterModel.isFinishedDownloading) {
                guard let selectedReciterId = selectedReciterId else { return }
                
                reciterModel.reciterId = selectedReciterId
                
                showReciterPicker = false
            }
            .navigationTitle("Reciters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Toolbar(showReciterPicker: $showReciterPicker, downloading: downloading)
            }
        }
    }
    
    private func reciterCard(for reciter: Reciter) -> some View {
        Button {
            selectedReciterId = reciter.id
            
            playBismillah(for: reciter)
        } label: {
            ReciterCard(reciter: reciter, selectedReciterId: selectedReciterId ?? reciterModel.reciterId)
        }
    }
    
    private func playBismillah(for reciter: Reciter) {
        player?.pause()
        
        guard let url = Bundle.main.url(forResource: reciter.localAsset, withExtension: "mp3") else { return }
        
        player = AVPlayer(url: url)
        player?.play()
    }
    
    @ViewBuilder
    private var downloadBar: some View {
        if downloading {
            HStack {
                playPauseDownloadButton
                
                ProgressView(value: reciterModel.progress, total: 1)
                    .progressViewStyle(.linear)
                
                cancelDownloadButton
            }
        }
    }
    
    private var playPauseDownloadButton: some View {
        Button {
            if reciterModel.isPaused {
                reciterModel.resumeDownload()
            } else {
                reciterModel.pauseDownload()
            }
        } label: {
            Image(systemName: reciterModel.isPaused ? "play.fill" : "pause.fill")
                .foregroundStyle(Color.primary)
                .padding(5)
        }
    }
    
    private var cancelDownloadButton: some View {
        Button {
            reciterModel.cancelDownload()
            
            downloading = false
        } label: {
            Image(systemName: "xmark.circle")
                .foregroundStyle(Color.red)
                .padding(5)
        }
    }
    
    @ViewBuilder
    private var continueButton: some View {
        if let selectedReciterId {
            Button {
                if !reciterModel.isRecitationDownloaded(for: selectedReciterId) {
                    reciterModel.startDownload(from: selectedReciterId)
                    
                    downloading = true
                } else {
                    reciterModel.reciterId = selectedReciterId
                    
                    showReciterPicker = false
                }
            } label: {
                Text(reciterModel.isRecitationDownloaded(for: selectedReciterId) ? "Select" : "Continue")
            }
            .buttonStyle(DefaultButtonStyle())
            .animation(.default, value: downloading)
            .padding()
        }
    }
    
    struct Toolbar: ToolbarContent {
        @Binding var showReciterPicker: Bool
        
        let downloading: Bool
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showReciterPicker = false
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                }.disabled(downloading)
            }
        }
    }
}

struct ReciterCard: View {
    let reciter: Reciter
    
    let selectedReciterId: Int?
    
    init(reciter: Reciter, selectedReciterId: Int? = nil) {
        self.reciter = reciter
        self.selectedReciterId = selectedReciterId
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(reciter.localAsset)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(selectedReciterId == reciter.id ? Color.accentColor : Color.primary, lineWidth: 2.5)
                }
            
            Text(reciter.name)
                .font(.system(.headline, weight: .bold))
                .foregroundStyle(Color.primary)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .frame(height: 50, alignment: .top)
        }.frame(width: 90)
    }
}

#Preview {
    ReciterPicker(reciterModel: ReciterModel(), showReciterPicker: .constant(true))
}
