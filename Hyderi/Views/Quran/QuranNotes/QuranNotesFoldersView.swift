//
//  QuranNotesFoldersView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import SwiftUI
import CoreData

struct QuranNotesFoldersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject private var quranNotesModel: QuranNotesModel = QuranNotesModel()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \QuranNotesFolder.dateModified, ascending: false)], animation: .default)
    private var quranNotesFolders: FetchedResults<QuranNotesFolder>
    
    let didSelectFolder: ((QuranNotesFolder) -> Void)?
    
    init(didSelectFolder: ((QuranNotesFolder) -> Void)? = nil) {
        self.didSelectFolder = didSelectFolder
    }
    
    @State private var newFolderTitle: String = ""
    @State private var showNewFolder: Bool = false
    
    var body: some View {
        List {
            ForEach(quranNotesFolders) { folder in
                if let didSelectFolder {
                    Button {
                        didSelectFolder(folder)
                    } label: {
                        FolderCard(folder: folder)
                    }
                } else {
                    Button {
                        quranNotesModel.folder = folder
                    } label: {
                        FolderCard(folder: folder)
                    }
                }
            }.onDelete(perform: deleteFolder)
        }
        .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
        .sheet(isPresented: $showNewFolder) {
            NewQuranNotesFolderView(title: $newFolderTitle, showNewFolder: $showNewFolder) {
                _ = QuranNotesFolder(context: viewContext, title: newFolderTitle, dateCreated: Date(), dateModified: Date(), quranNotes: Set())
                
                CoreDataManager.shared.save()
                
                newFolderTitle = ""
                showNewFolder = false
            }
        }
        .navigationDestination(item: $quranNotesModel.folder) { _ in
            QuranNotesView(quranNotesModel: quranNotesModel)
        }
        .toolbar {
            Toolbar(viewContext: viewContext, showNewFolder: $showNewFolder)
        }
        .tint(Color.yellow)
    }
    
    private func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            let folder = quranNotesFolders[index]
            
            viewContext.delete(folder)
        }
        
        CoreDataManager.shared.save()
    }
    
    private struct FolderCard: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        let folder: QuranNotesFolder
        
        @State private var didRename: (() -> Void)?
        @State private var rename: String = ""
        
        @FocusState private var renameFocused: Bool
        
        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .font(.title3)
                    .foregroundStyle(Color.yellow)
                
                if let didRename {
                    TextField("", text: $rename)
                        .focused($renameFocused)
                        .onSubmit {
                            didRename()
                        }
                } else {
                    Text(folder.title)
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                
                Text(String(folder.quranNotes.count))
                    .foregroundStyle(Color.secondary)
            }
            .contextMenu {
                Button("Rename", systemImage: "pencil") {
                    renameFolder()
                }
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deleteFolder()
                }
            }
        }
        
        private func renameFolder() {
            rename = folder.title
            renameFocused = true
            
            didRename = {
                folder.title = rename
                
                CoreDataManager.shared.save()
                
                didRename = nil
                rename = ""
                renameFocused = false
            }
        }
        
        private func deleteFolder() {
            viewContext.delete(folder)
            
            CoreDataManager.shared.save()
        }
    }
    
    private struct Toolbar: ToolbarContent {
        let viewContext: NSManagedObjectContext
        
        @Binding var showNewFolder: Bool
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewFolder = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
    }
}

#Preview {
    QuranNotesFoldersView()
}
