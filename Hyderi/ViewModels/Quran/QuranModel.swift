//
//  QuranModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI

class QuranModel: ObservableObject {
    @Published var quran: [Surah] = []
    @Published var translators: [Translator] = []
    
    @Published var searchText: String = ""
    
    @AppStorage("translatorId") var translatorId: Int = 0
    @AppStorage("wordByWordLanguageCode") var wordByWordLanguageCode: String = ""
    
    init() {
        loadQuran()
        loadTranslators()
        
        self.autoLoadTranslation {
            self.autoLoadWordByWord()
        }
    }
    
    private func loadQuran() {
        guard let quran = JSONDecoder.decode(from: "Quran", to: [Surah].self) else { return }
        
        self.quran = quran
    }
    
    private func loadTranslators() {
        guard let translators = JSONDecoder.decode(from: "Translators", to: [Translator].self) else { return }
        
        self.translators = translators.sorted { translator1, translator2 in
            if translator1.language == translator2.language {
                return translator1.name < translator2.name
            }
            
            return translator1.language < translator2.language
        }
    }
}

extension QuranModel {
    var filteredQuran: [Surah] {
        guard !searchText.isEmpty else { return quran }
        
        let searchText = searchText.lowercased()
        
        return quran.filter { surah in
            if searchText == String(surah.id) { return true }
            if surah.name.lowercased().contains(searchText) { return true }
            if surah.transliteration.lowercased().contains(searchText) { return true }
            if surah.translation.lowercased().contains(searchText) { return true }
            
            return false
        }
    }
    
    var filteredVerses: [(id: String, surah: Surah, verseId: Int)] {
        guard !searchText.isEmpty else { return [] }
        
        let verses = quran.flatMap { surah in
            surah.verses.map({ (surah, $0) })
        }
        
        let searchText = searchText.lowercasedLetters()
        
        return verses.filter { surah, verse in
            guard let translation = verse.translation?.translation.lowercasedLetters() else { return false }
            
            return translation.contains(searchText)
        }.map({ ("\($0.0.id)-\($0.1.id)", $0.0, $0.1.id) })
    }
    
    var surahAndVerse: (surah: Surah, verseId: Int)? {
        let components = searchText.split(separator: ":")
        
        guard components.count == 2, let surahPart = components.first?.lowercased(), let versePart = components.last, let verseId = Int(versePart) else { return nil }
        
        if let surah = quran.first(where: { surah in
            if surah.id == Int(surahPart) { return true }
            if surah.name.lowercased() == surahPart { return true }
            if surah.transliteration.lowercased() == surahPart { return true }
            if surah.translation.lowercased() == surahPart { return true }
            
            return false
        }) {
            return (1...surah.totalVerses).contains(verseId) ? (surah, verseId) : nil
        }
        
        return nil
    }
}

extension QuranModel {
    func isTranslationDownloaded(for translatorId: Int) -> Bool {
        let fileManager = FileManager.default
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("translation-\(translatorId).json") else { return false }
        
        return fileManager.fileExists(atPath: fileURL.path())
    }
    
    func autoLoadTranslation(completion: @escaping () -> Void) {
        if isTranslationDownloaded(for: translatorId) {
            loadTranslation(for: translatorId, completion: completion)
        } else {
            downloadTranslation(from: .khattabId)
            translatorId = .khattabId
        }
    }
    
    func downloadTranslation(from translatorId: Int, oldTranslatorId: Int? = nil) {
        guard let url = URL(string: "https://api.quran.com/api/v4/quran/translations/\(translatorId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data else { return }
            
            let fileManager = FileManager.default
            
            guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("translation-\(translatorId).json") else { return }
            
            try? data.write(to: fileURL)
            
            if let oldTranslatorId, oldTranslatorId != translatorId {
                self.deletePreviousTranslation(for: oldTranslatorId)
            }
            
            self.loadTranslation(for: translatorId)
        }.resume()
    }
    
    private func deletePreviousTranslation(for translatorId: Int) {
        let fileManager = FileManager.default
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("translation-\(translatorId).json") else { return }
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    func loadTranslation(for translatorId: Int, completion: @escaping () -> Void = {}) {
        let fileManager = FileManager.default
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("translation-\(translatorId).json") else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            let jsonData = try JSONDecoder().decode(Translation.self, from: data)
            let translations = jsonData.translations
            
            var translationIndex = 0
            
            var quran = self.quran
            
            for surah in quran.indices {
                for verse in quran[surah].verses.indices {
                    if !quran[surah].verses[verse].translations.contains(where: { $0.id == translatorId }) {
                        let translation = cleanTranslationVerse(translations[translationIndex].text)
                        let verseTranslation = VerseTranslation(id: translatorId, translation: translation)
                        
                        quran[surah].verses[verse].translations.append(verseTranslation)
                    }
                    
                    translationIndex += 1
                }
            }
            
            DispatchQueue.main.async {
                self.quran = quran
                
                completion()
            }
        } catch {
            
        }
    }
    
    private func cleanTranslationVerse(_ verse: String) -> String {
        let pattern = "<[^>]+>[^<]+<[^>]+>"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(verse.startIndex..<verse.endIndex, in: verse)
            let cleanedVerse = regex.stringByReplacingMatches(in: verse, options: [], range: range, withTemplate: "")
            
            return cleanedVerse
        } catch {
            return verse
        }
    }
}

extension Int {
    static let khattabId = 131
}

extension QuranModel {
    func isWordByWordDownloaded(for languageCode: String) -> Bool {
        let fileManager = FileManager.default
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("wordByWord-\(languageCode).json") else { return false }
        
        return fileManager.fileExists(atPath: fileURL.path())
    }
    
    func autoLoadWordByWord() {
        if isWordByWordDownloaded(for: wordByWordLanguageCode) {
            loadWordByWord(for: wordByWordLanguageCode)
        } else {
            downloadWordByWord(from: .englishCode)
            translatorId = .khattabId
        }
    }
    
    func downloadWordByWord(from languageCode: String, oldLanguageCode: String? = nil) {
        guard let url = URL(string: "https://raw.githubusercontent.com/hablullah/data-quran/refs/heads/master/word-translation/\(languageCode)-qurancom.json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data else { return }
            
            let fileManager = FileManager.default
            
            guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("wordByWord-\(languageCode).json") else { return }
            
            try? data.write(to: fileURL)
            
            if let oldLanguageCode, oldLanguageCode != languageCode {
                self.deletePreviousWordByWord(for: oldLanguageCode)
            }
            
            self.loadWordByWord(for: languageCode)
        }.resume()
    }
    
    private func deletePreviousWordByWord(for languageCode: String) {
        let fileManager = FileManager.default
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("wordByWord-\(languageCode).json") else { return }
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    func loadWordByWord(for languageCode: String) {
        let fileManager = FileManager.default
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("wordByWord-\(languageCode).json") else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            let wordTranslations = try JSONDecoder().decode([String : String].self, from: data)
            
            var wordTranslationIndex = 1
            
            var quran = self.quran
            
            for surah in quran.indices {
                for verse in quran[surah].verses.indices {
                    for word in quran[surah].verses[verse].words.indices {
                        if !quran[surah].verses[verse].words[word].translations.contains(where: { $0.id == languageCode }), let translation = wordTranslations[String(wordTranslationIndex)] {
                            let wordTranslation = WordTranslation(id: languageCode, translation: translation)
                            
                            quran[surah].verses[verse].words[word].translations.append(wordTranslation)
                        }
                        
                        wordTranslationIndex += 1
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.quran = quran
            }
        } catch {
            print(error)
        }
    }
}

extension String {
    static let englishCode = "en"
}
