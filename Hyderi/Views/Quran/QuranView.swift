//
//  QuranView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI

struct QuranView: View {
    @StateObject private var quranModel: QuranModel = QuranModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(quranModel.quran) { surah in
                    NavigationLink {
                        SurahView(surah: surah)
                    } label: {
                        SurahCard(surah: surah)
                    }
                }
            }.padding(10)
        }
    }
    
    struct SurahCard: View {
        let surah: Surah
        
        var body: some View {
            HStack(spacing: 10) {
                ZStack {
                    Image(systemName: "diamond")
                        .font(.system(size: 40, weight: .ultraLight))
                    
                    Text(String(surah.id))
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Text(surah.transliteration)
                        .font(.system(.headline, weight: .bold))
                    
                    Text(surah.translation)
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(surah.name)
                        .font(.system(.headline, weight: .bold))
                    
                    Text("\(surah.total_verses) Ayahs")
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }
            .foregroundStyle(Color.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding([.vertical, .trailing], 15)
            .padding(.leading, 10)
            .secondaryRoundedBackground(cornerRadius: 5)
        }
    }
}

#Preview {
    QuranView()
}
