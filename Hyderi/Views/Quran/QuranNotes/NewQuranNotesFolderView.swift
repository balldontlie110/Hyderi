//
//  NewQuranNotesFolderView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/16/24.
//

import SwiftUI

struct NewQuranNotesFolderView: View {
    @Binding var title: String
    @Binding var showNewFolder: Bool
    
    let done: () -> Void
    
    @FocusState private var focused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("", text: $title)
                        .focused($focused)
                    
                    Spacer()
                    
                    Button {
                        title = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(.systemBackground), Color.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .secondaryRoundedBackground(cornerRadius: 10)
                .padding()
                
                Spacer()
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Toolbar(title: $title, showNewFolder: $showNewFolder, done: done)
            }
        }
        .onAppear {
            focused = true
        }
        .onDisappear {
            title = ""
        }
        .tint(Color.yellow)
    }
    
    private struct Toolbar: ToolbarContent {
        @Binding var title: String
        @Binding var showNewFolder: Bool
        
        let done: () -> Void
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    title = ""
                    showNewFolder = false
                } label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    done()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                }.disabled(title.isEmpty)
            }
        }
    }
}

#Preview {
    NewQuranNotesFolderView(title: .constant(""), showNewFolder: .constant(true), done: {})
}
