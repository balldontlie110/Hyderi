//
//  SurahView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI
import CoreData

struct SurahView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.quranTimes) private var quranTimes
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject private var reciterModel: ReciterModel = ReciterModel()
    @AppStorage("reciterId") private var reciterId = 0
    
    @AppStorage("wordByWord") private var wordByWord = false
    
    let surah: Surah
    
    @State private var selectedTab: SelectedTab = .translation
    
    private enum SelectedTab {
        case translation, reading
    }
    
    @State private var scrollPosition: Int?
    
    @State private var timer: Timer?
    
    init(surah: Surah, scrollPosition: Int? = nil) {
        self.surah = surah
        self._scrollPosition = State(wrappedValue: scrollPosition)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let fullScreen = proxy.size.width > proxy.size.height
            
            TabView(selection: $selectedTab) {
                Tab("Translation", systemImage: "book.closed", value: .translation) {
                    TranslationView(surah: surah, scrollPosition: $scrollPosition, surahTitle: surahTitle, wordByWord: wordByWord, playPauseVerseAudio: playPauseVerseAudio)
                        .toolbar(fullScreen ? .hidden : .visible, for: .tabBar)
                        .toolbar(fullScreen ? .hidden : .visible, for: .navigationBar)
                }
                
                Tab("Reading", systemImage: "book", value: .reading) {
                    ReadingView(surah: surah, scrollPosition: $scrollPosition, surahTitle: surahTitle, playPauseVerseAudio: playPauseVerseAudio)
                        .toolbar(fullScreen ? .hidden : .visible, for: .tabBar)
                        .toolbar(fullScreen ? .hidden : .visible, for: .navigationBar)
                }
            }
            .onChange(of: selectedTab) {
                adjustScrollPosition()
            }
            .onRotate {
                adjustScrollPosition()
            }
            .onAppear {
                audioPlayer.canDismissAudioSlider = false
                audioPlayer.tabView = true
                
                adjustScrollPosition()
                startQuranTime()
            }
            .onDisappear {
                audioPlayer.canDismissAudioSlider = true
                audioPlayer.tabView = false
                
                endQuranTime()
                
                if audioPlayer.currentTime == 0 {
                    audioPlayer.forceAudioSlider = false
                }
            }
            .onChange(of: scenePhase) {
                handleScenePhaseChange()
            }
            .onChange(of: proxy.size) {
                audioPlayer.tabView = !fullScreen
            }
            .navigationTitle(surah.transliteration)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                Toolbar(continueAudio: $audioPlayer.continueAudio, wordByWord: $wordByWord, selectedTab: selectedTab)
            }
        }
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
    
    private struct Toolbar: ToolbarContent {
        @Binding var continueAudio: Bool
        @Binding var wordByWord: Bool
        
        let selectedTab: SelectedTab
        
        var body: some ToolbarContent {
            if selectedTab == .translation {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        wordByWord.toggle()
                    } label: {
                        Image(systemName: "translate")
                            .foregroundStyle(wordByWord ? Color.accentColor : Color.secondary)
                            .frame(width: 30, alignment: .center)
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    continueAudio.toggle()
                } label: {
                    Image(systemName: "repeat")
                        .foregroundStyle(continueAudio ? Color.accentColor : Color.secondary)
                        .frame(width: 30, alignment: .center)
                }
            }
        }
    }
    
    private func adjustScrollPosition() {
        let scrollPosition = self.scrollPosition
        self.scrollPosition = nil
        
        Task { @MainActor in
            self.scrollPosition = scrollPosition
        }
    }
}

extension SurahView {
    func playPauseVerseAudio(for verse: SurahVerse, surahVerse: String) {
        audioPlayer.forceAudioSlider = true
        
        if audioPlayer.activeAudioId != surahVerse {
            guard let reciter, let verseAudioUrl = getVerseAudioUrl(for: verse, by: reciter) else { return }
            
            audioPlayer.initialisePlayer(with: verseAudioUrl, id: surahVerse, title: surah.transliteration, subtitle: surahVerse) {
                offsetVerseAction(for: verse, by: -1)
            } nextVerseAction: {
                offsetVerseAction(for: verse, by: 1)
            }
            
            audioPlayer.play()
        } else {
            audioPlayer.playPause()
        }
    }
    
    private var reciter: Reciter? {
        reciterModel.reciters.first(where: { $0.id == reciterId })
    }
    
    private func getVerseAudioUrl(for verse: SurahVerse, by reciter: Reciter) -> URL? {
        let fileManager = FileManager.default
        
        guard let extractionURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(reciter.localAsset)") else { return nil }
        
        let mp3s = try? fileManager.contentsOfDirectory(at: extractionURL, includingPropertiesForKeys: nil).filter({ $0.pathExtension == "mp3" })
        
        return mp3s?.first(where: { $0.lastPathComponent == "\(verse.audio).mp3" })
    }
    
    private func offsetVerseAction(for verse: SurahVerse, by offset: Int) {
        guard let offsetVerse = surah.verses.first(where: { $0.id == verse.id + offset }) else { return }
        
        let surahVerse = "\(surah.id):\(offsetVerse.id)"
        
        playPauseVerseAudio(for: offsetVerse, surahVerse: surahVerse)
        
        withAnimation {
            scrollPosition = offsetVerse.id
        }
    }
}

extension SurahView {
    func startQuranTime() {
        if let day = quranTimes.first(where: { Calendar.current.isDateInToday($0.date) }) {
            startTimer(for: day)
        } else {
            startTimer(for: newQuranTime())
        }
    }
    
    private func newQuranTime() -> QuranTime {
        return QuranTime(context: viewContext, date: Date().startOfDay(), time: 0)
    }
    
    private func startTimer(for day: QuranTime) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            day.time = day.time + Int64(1)
        }
        
        guard let timer else { return }
        
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func endQuranTime() {
        self.timer?.invalidate()
        
        QuranTimeModel.updateStreak(quranTimes: quranTimes)
        
        CoreDataManager.shared.save()
    }
    
    func handleScenePhaseChange() {
        switch scenePhase {
        case .active:
            startQuranTime()
            audioPlayer.startDisplayLink()
        case .inactive:
            endQuranTime()
            audioPlayer.stopDisplayLink()
        case .background:
            endQuranTime()
            audioPlayer.stopDisplayLink()
        @unknown default:
            return
        }
    }
}

#Preview {
    let surah: Surah? = nil
    
    if let surah {
        SurahView(surah: surah)
    }
}
