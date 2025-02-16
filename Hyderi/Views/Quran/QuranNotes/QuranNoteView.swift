//
//  QuranNoteView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import SwiftUI
import CoreData

struct QuranNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject private var quranModel: QuranModel
    
    @StateObject var quranNotesModel: QuranNotesModel
    
    @State private var title: String = ""
    @State private var note: String = ""
    
    private let surahId: Int?
    @State private var verseIds: [Int]?
    
    private let verseNavigates: Bool
    
    init(quranNotesModel: QuranNotesModel) {
        self._quranNotesModel = StateObject(wrappedValue: quranNotesModel)
        
        if let quranNote = quranNotesModel.note {
            self.title = quranNote.title
            self.note = quranNote.note
            
            self.surahId = Int(quranNote.surahId)
            self.verseIds = quranNote.verseIds
        } else {
            self.surahId = nil
            self.verseIds = nil
        }
        
        self.verseNavigates = true
    }
    
    init(surahId: Int, verseId: Int) {
        self._quranNotesModel = StateObject(wrappedValue: QuranNotesModel())
        
        self.surahId = surahId
        self.verseIds = [verseId]
        
        self.verseNavigates = false
    }
    
    enum FocusedField {
        case title, note
    }
    
    @FocusState private var focused: FocusedField?
    
    @State private var showFolderSelection: Bool = false
    
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                lastModified
                
                verses
                
                HStack {
                    addVerseButton
                    
                    Spacer()
                    
                    removeVerseButton
                }
                
                Divider()
                
                TextField("Title", text: $title, axis: .vertical)
                    .font(.system(.title, weight: .bold))
                    .focused($focused, equals: .title)
                
                TextField("Content", text: $note, axis: .vertical)
                    .focused($focused, equals: .note)
            }
            .padding(10)
            .safeAreaPadding(.bottom, 100)
        }
        .onTapGesture { focused = .note }
        .onAppear { focused = .title }
        .sheet(isPresented: $showFolderSelection) {
            NavigationStack {
                QuranNotesFoldersView(didSelectFolder: didSelectFolder)
            }
        }
        .confirmationDialog("Delete Note", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteNote()
            }
        } message: {
            Text("Are you sure you want do delete this note? This action cannot be undone.")
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Toolbar(note: quranNotesModel.note, focused: $focused, canSaveChanges: canSaveChanges, saveChanges: saveChanges, showDeleteConfirmation: $showDeleteConfirmation)
        }
        .tint(Color.yellow)
    }
    
    private var navigationTitle: String {
        guard let surahId, let verseIds else { return "" }
        
        if let firstVerseId = verseIds.first {
            if let lastVerseId = verseIds.last, lastVerseId != firstVerseId {
                return "\(surahId):\(firstVerseId)-\(lastVerseId)"
            }
            
            return "\(surahId):\(firstVerseId)"
        }
        
        return String(surahId)
    }
    
    @ViewBuilder
    private var lastModified: some View {
        if let quranNote = quranNotesModel.note {
            Text("\(quranNote.dateModified.date()) at \(quranNote.dateModified.time())")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var verses: some View {
        if let quranNoteVerses {
            LazyVStack {
                ForEach(quranNoteVerses) { verse in
                    NavigationLink {
                        if let quranNoteSurah {
                            SurahView(surah: quranNoteSurah, scrollPosition: verse.id)
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Text(verse.text)
                                .bold()
                            
                            if let translation = verse.translation {
                                Text(translation.translation)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)
                    }
                }.disabled(!verseNavigates || quranNoteSurah == nil)
            }
        }
    }
    
    private var quranNoteSurah: Surah? {
        guard let surahId else { return nil }
        
        return quranModel.quran.first(where: { $0.id == Int(surahId) })
    }
    
    private var quranNoteVerses: [SurahVerse]? {
        guard let verseIds else { return nil }
        
        return quranNoteSurah?.verses.filter({ verseIds.contains($0.id) })
    }
    
    private var addVerseButton: some View {
        Button {
            addVerse()
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                
                Text("Add Verse")
            }
            .font(.system(.subheadline, weight: .medium))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BorderedButtonStyle())
        .disabled(verseIds?.last == quranNoteSurah?.totalVerses)
    }
    
    private func addVerse() {
        guard let lastVerseId = quranNoteVerses?.last?.id else { return }
        guard let nextVerseId = quranNoteSurah?.verses.first(where: { $0.id == lastVerseId + 1 })?.id else { return }
        
        quranNotesModel.note?.verseIds.append(nextVerseId)
        CoreDataManager.shared.save()
        
        verseIds?.append(nextVerseId)
    }
    
    private var removeVerseButton: some View {
        Button {
            removeVerse()
        } label: {
            HStack {
                Image(systemName: "minus.circle")
                
                Text("Remove Verse")
            }
            .font(.system(.subheadline, weight: .medium))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BorderedButtonStyle())
        .disabled(verseIds?.count == 1)
    }
    
    private func removeVerse() {
        quranNotesModel.note?.verseIds.removeLast()
        CoreDataManager.shared.save()
        
        verseIds?.removeLast()
    }
    
    private var canSaveChanges: Bool {
        !title.isEmpty
    }
    
    private var noteHasChanges: Bool {
        if let quranNote = quranNotesModel.note {
            return title != quranNote.title || note != quranNote.note
        }
        
        return true
    }
    
    private func saveChanges() {
        guard canSaveChanges, noteHasChanges else { return }
        
        guard let quranNote = quranNotesModel.note else {
            showFolderSelection = true
            
            return
        }
        
        quranNote.title = title.trimmingWhitespace()
        quranNote.note = note.trimmingWhitespace()
        quranNote.dateModified = Date()
        
        quranNote.folder?.dateModified = Date()
        
        CoreDataManager.shared.save()
    }
    
    private func didSelectFolder(folder: QuranNotesFolder) {
        showFolderSelection = false
        
        guard let surahId, let verseIds else { return }
        
        let quranNote = QuranNote(context: viewContext, title: title.isEmpty ? String(note.prefix(100)) : title, note: note, surahId: surahId, verseIds: verseIds, dateCreated: Date(), dateModified: Date(), folder: folder)
        
        quranNotesModel.note = quranNote
        
        var quranNotes = Array(folder.quranNotes)
        quranNotes.append(quranNote)
        
        folder.dateModified = Date()
        folder.quranNotes = Set(quranNotes)
        
        CoreDataManager.shared.save()
    }
    
    private func deleteNote() {
        if let quranNote = quranNotesModel.note {
            viewContext.delete(quranNote)
            
            CoreDataManager.shared.save()
        }
        
        quranNotesModel.note = nil
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private struct Toolbar: ToolbarContent {
        let note: QuranNote?
        
        @FocusState.Binding var focused: FocusedField?
        
        let canSaveChanges: Bool
        let saveChanges: () -> Void
        
        @Binding var showDeleteConfirmation: Bool
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                if focused == nil {
                    Button {
                        showDeleteConfirmation.toggle()
                    } label: {
                        Image(systemName: "trash")
                    }
                } else {
                    Button {
                        focused = nil
                        
                        saveChanges()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }.disabled(!canSaveChanges)
                }
            }
        }
    }
}

#Preview {
    QuranNoteView(quranNotesModel: QuranNotesModel())
}
