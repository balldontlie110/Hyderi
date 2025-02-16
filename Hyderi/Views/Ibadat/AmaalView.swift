//
//  AmaalView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct AmaalView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject var quranModel: QuranModel
    
    let amaal: Amaal
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                description
                
                Divider()
                
                ForEach(Array(amaal.sections.enumerated()), id: \.offset) { index, section in
                    Section(quranModel: quranModel, section: section)
                    
                    if index != amaal.sections.count - 1 {
                        Divider()
                    }
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 50)
        }
        .navigationTitle(amaal.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }
    
    private var description: some View {
        Text(amaal.description)
            .font(.system(.headline, weight: .bold))
            .padding(.horizontal)
    }
    
    private struct Section: View {
        @StateObject var quranModel: QuranModel
        
        let section: AmaalSection
        
        var body: some View {
            description
            
            ForEach(section.details) { detail in
                SectionDetail(quranModel: quranModel, detail: detail)
            }
        }
        
        private var description: some View {
            Text(section.description)
                .font(.system(.headline, weight: .bold))
        }
        
        private struct SectionDetail: View {
            @StateObject var quranModel: QuranModel
            
            let detail: AmaalSectionDetail
            
            @State private var revealed: Bool = false
             
            var body: some View {
                heading
                
                sectionBody
                
                link
            }
            
            @ViewBuilder
            private var heading: some View {
                if let heading = detail.heading {
                    HStack {
                        Text(heading)
                            .font(.system(.headline, weight: .bold))
                            .foregroundStyle(Color.secondary)
                        
                        Button {
                            revealed.toggle()
                        } label: {
                            Image(systemName: revealed ? "chevron.up" : "chevron.down")
                                .bold()
                        }
                    }
                }
            }
            
            @ViewBuilder
            private var sectionBody: some View {
                if revealed || detail.heading == nil {
                    if let surahId = detail.surahId {
                        SurahView(quranModel: quranModel, surahId: surahId)
                    } else if let body = detail.body {
                        ForEach(body) { verse in
                            IbadahVerseView(verse: verse)
                        }
                    }
                }
            }
            
            private struct SurahView: View {
                @StateObject var quranModel: QuranModel
                
                let surahId: Int
                
                var body: some View {
                    if let surah {
                        ForEach(surah.verses) { verse in
                            VStack(spacing: 15) {
                                arabicVerseText(verse)
                                
                                verseTranslation(verse)
                            }.padding(.vertical)
                        }
                    }
                }
                
                private var surah: Surah? {
                    return quranModel.quran.first(where: { $0.id == surahId })
                }
                
                private func arabicVerseText(_ verse: SurahVerse) -> some View {
                    Text(verse.text)
                        .font(.system(size: 40, weight: .bold))
                        .lineSpacing(10)
                }
                
                @ViewBuilder
                private func verseTranslation(_ verse: SurahVerse) -> some View {
                    if let translation = verse.translation {
                        Text(translation.translation)
                            .font(.system(size: 20))
                    }
                }
            }
            
            @ViewBuilder
            private var link: some View {
                if let urlString = detail.url, let url = URL(string: urlString), let linkTitle = detail.linkTitle {
                    Link(linkTitle, destination: url)
                }
            }
        }
    }
}

#Preview {
    let amaal: Amaal? = nil
    
    if let amaal {
        AmaalView(quranModel: QuranModel(), amaal: amaal)
    }
}
