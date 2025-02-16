//
//  QuranNotesView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import SwiftUI
import CoreData

struct QuranNotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject var quranNotesModel: QuranNotesModel
    
    @State private var quranNoteToMove: QuranNote?
    
    var body: some View {
        if let folder = quranNotesModel.folder {
            List {
                ForEach(folder.quranNotes.sorted(by: { $0.dateModified > $1.dateModified })) { quranNote in
                    Button {
                        quranNotesModel.note = quranNote
                    } label: {
                        QuranNoteCard(quranNote: quranNote, quranNoteToMove: $quranNoteToMove)
                    }
                }.onDelete(perform: deleteNotes)
            }
            .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
            .navigationDestination(item: $quranNotesModel.note) { _ in
                QuranNoteView(quranNotesModel: quranNotesModel)
            }
            .sheet(item: $quranNoteToMove) { oldQuranNote in
                NavigationStack {
                    QuranNotesFoldersView { newFolder in
                        quranNoteToMove = nil
                        
                        let newQuranNote = QuranNote(context: viewContext, from: oldQuranNote, folder: newFolder)
                        
                        var quranNotes = Array(newFolder.quranNotes)
                        quranNotes.append(newQuranNote)
                        
                        newFolder.dateModified = Date()
                        newFolder.quranNotes = Set(quranNotes)
                        
                        if let oldFolder = oldQuranNote.folder, let note = Array(oldFolder.quranNotes).first(where: { $0 == oldQuranNote }) {
                            viewContext.delete(note)
                        }
                        
                        CoreDataManager.shared.save()
                    }
                }
            }
            .tint(Color.yellow)
        }
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        guard let folder = quranNotesModel.folder else { return }
        
        for index in offsets {
            let note = Array(folder.quranNotes)[index]
            
            viewContext.delete(note)
        }
        
        CoreDataManager.shared.save()
    }
    
    private struct QuranNoteCard: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        let quranNote: QuranNote
        
        @Binding var quranNoteToMove: QuranNote?
        
        var body: some View {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(quranNote.title)
                        .font(.system(.headline, weight: .bold))
                        .foregroundStyle(Color.primary)
                    
                    HStack(spacing: 10) {
                        Text(verseRange)
                            .monospaced()
                        
                        Text(quranNote.note)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                }.lineLimit(1)
                
                Spacer()
            }
            .contextMenu {
                Button("Move", systemImage: "folder") {
                    quranNoteToMove = quranNote
                }
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deleteNote()
                }
            }
        }
        
        private var verseRange: String {
            if let firstVerseId = quranNote.verseIds.first {
                if let lastVerseId = quranNote.verseIds.last, lastVerseId != firstVerseId {
                    return "\(quranNote.surahId):\(firstVerseId)-\(lastVerseId)"
                }
                
                return "\(quranNote.surahId):\(firstVerseId)"
            }
            
            return String(quranNote.surahId)
        }
        
        private func deleteNote() {
            viewContext.delete(quranNote)
            
            CoreDataManager.shared.save()
        }
    }
}

#Preview {
    QuranNotesView(quranNotesModel: QuranNotesModel())
}
