//
//  IbadatView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct IbadatView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject var quranModel: QuranModel
    
    let ibadahType: IbadahType
    
    enum IbadahType: String {
        case duas = "Du'as"
        case ziaraah = "Ziaraah"
        case amaals = "Amaals"
        case nasheeds = "Nasheeds"
        
        var ibadat: [Ibadah] {
            switch self {
            case .duas:
                return DuaModel().duas
            case .ziaraah:
                return ZiyaratModel().ziaraah
            case .amaals:
                return AmaalModel().amaals
            case .nasheeds:
                return NasheedModel().nasheeds
            }
        }
        
        func view<I: Ibadah>(for ibadah: I, quranModel: QuranModel) -> any View {
            switch self {
            case .duas:
                if let dua = ibadah as? Dua {
                    return DuaView(dua: dua)
                }
            case .ziaraah:
                if let ziyarat = ibadah as? Ziyarat {
                    return ZiyaratView(ziyarat: ziyarat)
                }
            case .amaals:
                if let amaal = ibadah as? Amaal {
                    return AmaalView(quranModel: quranModel, amaal: amaal)
                }
            case .nasheeds:
                if let nasheed = ibadah as? Nasheed {
                    return NasheedView(nasheed: nasheed)
                }
            }
            
            return EmptyView()
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(ibadahType.ibadat, id: \.id) { ibadah in
                    NavigationLink {
                        AnyView(ibadahType.view(for: ibadah, quranModel: quranModel))
                    } label: {
                        IbadahCard(ibadah: ibadah)
                    }
                }
            }
            .padding(10)
            .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
        }
        .navigationTitle(ibadahType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            Toolbar(audioPlayer: audioPlayer, ibadahType: ibadahType, playIbadah: playIbadah, getRandomIbadahId: getRandomIbadahId)
        }
    }
    
    struct IbadahCard: View {
        let ibadah: Ibadah
        
        var body: some View {
            HStack(spacing: 10) {
                ZStack {
                    Image(systemName: "diamond")
                        .font(.system(size: 40, weight: .ultraLight))
                    
                    Text(String(ibadah.id))
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Text(ibadah.title)
                        .font(.system(.headline, weight: .bold))
                    
                    if let subtitle = ibadah.subtitle {
                        Text(subtitle)
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Spacer()
            }
            .foregroundStyle(Color.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding([.vertical, .trailing], 15)
            .padding(.leading, 10)
            .secondaryRoundedBackground(cornerRadius: 5)
        }
    }
    
    struct Toolbar: ToolbarContent {
        @StateObject var audioPlayer: AudioPlayer
        
        let ibadahType: IbadatView.IbadahType
        
        let playIbadah: () -> Void
        
        let getRandomIbadahId: (Int?) -> Int?
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if ibadahType != audioPlayer.ibadahType || audioPlayer.playNextIbadah == nil {
                        audioPlayer.ibadahId = getRandomIbadahId(nil)
                        
                        playIbadah()
                    } else {
                        audioPlayer.playPause()
                    }
                } label: {
                    Image(systemName: ibadahType == audioPlayer.ibadahType && audioPlayer.playNextIbadah != nil && audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundStyle(Color.primary)
                        .frame(width: 30, alignment: .center)
                }
            }
        }
    }
    
    private func playIbadah() {
        switch ibadahType {
        case .duas:
            guard let dua = ibadahType.ibadat.first(where: { $0.id == audioPlayer.ibadahId }) as? Dua, let audio = dua.audio, let url = Bundle.main.url(forResource: audio, withExtension: "m4a") else {
                audioPlayer.resetPlayer()
                
                return
            }
            
            initialisePlayer(with: url, id: "dua-\(dua.id)", title: dua.title, subtitle: dua.subtitle)
        case .ziaraah:
            guard let ziyarat = ibadahType.ibadat.first(where: { $0.id == audioPlayer.ibadahId }) as? Ziyarat, let audio = ziyarat.audio, let url = Bundle.main.url(forResource: audio, withExtension: "m4a") else {
                audioPlayer.resetPlayer()
                
                return
            }
            
            initialisePlayer(with: url, id: "ziyarat-\(ziyarat.id)", title: ziyarat.title, subtitle: ziyarat.title)
        case .nasheeds:
            guard let nasheed = ibadahType.ibadat.first(where: { $0.id == audioPlayer.ibadahId }) as? Nasheed, let audio = nasheed.audios.randomElement(), let url = Bundle.main.url(forResource: audio.audio, withExtension: "m4a") else {
                audioPlayer.resetPlayer()
                
                return
            }
            
            audioPlayer.selectedNasheedAudioId = audio.id
            
            initialisePlayer(with: url, id: "nasheed-\(nasheed.id)", title: "\(nasheed.title) - \(audio.title)", subtitle: nasheed.subtitle)
        default:
            return
        }
        
        func initialisePlayer(with url: URL, id: String, title: String, subtitle: String?) {
            audioPlayer.forceAudioSlider = true
            audioPlayer.canDismissAudioSlider = false
            
            audioPlayer.ibadahType = ibadahType
            
            audioPlayer.pause()
            audioPlayer.initialisePlayer(with: url, id: id, title: title, subtitle: subtitle, nextVerseAction: playIbadah, playNextIbadah: playIbadah)
            audioPlayer.play()
            
            if let randomIbadahId = getRandomIbadahId(except: audioPlayer.ibadahId) {
                audioPlayer.ibadahId = randomIbadahId
            }
        }
    }
    
    private func getRandomIbadahId(except ibadahId: Int? = nil) -> Int? {
        switch ibadahType {
        case .duas:
            return (ibadahType.ibadat as? [Dua])?.compactMap({ $0.audio == nil || $0.id == ibadahId ? nil : $0.id }).randomElement()
        case .ziaraah:
            return (ibadahType.ibadat as? [Ziyarat])?.compactMap({ $0.audio == nil || $0.id == ibadahId ? nil : $0.id }).randomElement()
        case .nasheeds:
            return (ibadahType.ibadat as? [Nasheed])?.compactMap({ $0.id == ibadahId ? nil : $0.id }).randomElement()
        default:
            return nil
        }
    }
}

#Preview {
    IbadatView(quranModel: QuranModel(), ibadahType: .duas)
}
