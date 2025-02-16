//
//  TranslatorPicker.swift
//  Hyderi
//
//  Created by Ali Earp on 12/11/24.
//

import SwiftUI
import WStack

struct TranslatorPicker: View {
    @StateObject var quranModel: QuranModel
    
    @Binding var showTranslatorPicker: Bool
    
    @State private var searchText: String = ""
    
    @State private var selectedTranslatorId: Int?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    Text("Choose a translator")
                        .font(.system(.title, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    WStack(translators, alignment: .center, spacing: 30, lineSpacing: 30) { translator in
                        translatorCard(for: translator)
                    }
                }
                .padding(10)
                .padding(.vertical)
                .safeAreaPadding(.bottom, 75)
            }
            .overlay(alignment: .bottom) {
                selectButton
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Translators")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Toolbar(showTranslatorPicker: $showTranslatorPicker)
            }
        }
    }
    
    private var translators: [Translator] {
        guard !searchText.isEmpty else { return quranModel.translators }
        
        let searchText = searchText.lowercasedLetters()
        
        return quranModel.translators.filter { translator in
            if translator.name.lowercasedLetters().contains(searchText) { return true }
            if translator.language.lowercasedLetters().contains(searchText) { return true }
            if translator.languageCode.lowercasedLetters().contains(searchText) { return true }
            
            return false
        }
    }
    
    private func translatorCard(for translator: Translator) -> some View {
        Button {
            selectedTranslatorId = translator.id
        } label: {
            TranslatorCard(translator: translator, selectedTranslatorId: selectedTranslatorId ?? quranModel.translatorId)
        }
    }
    
    @ViewBuilder
    private var selectButton: some View {
        if let selectedTranslatorId {
            Button {
                let wordByWordLanguageCode = wordByWordLanguageCode(for: selectedTranslatorId)
                
                if !quranModel.isTranslationDownloaded(for: selectedTranslatorId) {
                    quranModel.downloadTranslation(from: selectedTranslatorId, oldTranslatorId: quranModel.translatorId)
                    quranModel.downloadWordByWord(from: wordByWordLanguageCode, oldLanguageCode: quranModel.wordByWordLanguageCode)
                } else {
                    quranModel.loadTranslation(for: selectedTranslatorId)
                    quranModel.loadWordByWord(for: wordByWordLanguageCode)
                }
                
                quranModel.translatorId = selectedTranslatorId
                quranModel.wordByWordLanguageCode = wordByWordLanguageCode
                
                showTranslatorPicker = false
            } label: {
                Text("Select")
            }
            .buttonStyle(DefaultButtonStyle())
            .padding()
        }
    }
    
    private let wordByWordLanguageCodes: [String] = ["bn", "de", "en", "fa", "hi", "id", "inh", "ru", "ta", "tr", "ur"]
    
    private func wordByWordLanguageCode(for translatorId: Int) -> String {
        guard let translator = quranModel.translators.first(where: { $0.id == translatorId }) else { return .englishCode }
        
        return wordByWordLanguageCodes.contains(translator.languageCode) ? translator.languageCode : .englishCode
    }
    
    struct Toolbar: ToolbarContent {
        @Binding var showTranslatorPicker: Bool
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showTranslatorPicker = false
                } label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct TranslatorCard: View {
    let translator: Translator
    
    let selectedTranslatorId: Int?
    
    init(translator: Translator, selectedTranslatorId: Int? = nil) {
        self.translator = translator
        self.selectedTranslatorId = selectedTranslatorId
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(translator.name)
                .font(.system(.headline, weight: .bold))
                .padding(15)
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(selectedTranslatorId == translator.id ? Color.accentColor : Color.primary, lineWidth: 2.5)
                }
            
            Text(translator.language)
                .font(.system(.headline, weight: .bold))
                .lineLimit(1)
        }
        .foregroundStyle(Color.primary)
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.5)
        .frame(width: 90)
    }
}

#Preview {
    TranslatorPicker(quranModel: QuranModel(), showTranslatorPicker: .constant(false))
}
