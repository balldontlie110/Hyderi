//
//  RootView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI

struct RootView: View {
    @Namespace private var namespace
    
    private let navigationColumns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: navigationColumns) {
                    navigationButton(withIcon: Icon("book"), titled: "Quran", to: QuranView())
                    navigationButton(withIcon: Icon("calendar"), titled: "Calendar", to: CalendarView())
                    navigationButton(withIcon: Icon("list.bullet"), titled: "Events", to: EventsView())
                    
                    navigationButton(withIcon: Icon("hand.raised", mirror: true), titled: "Du'as", to: IbadatView(ibadahType: .duas))
                    navigationButton(withIcon: Icon("moon.dust"), titled: "Ziaraah", to: IbadatView(ibadahType: .ziaraah))
                    navigationButton(withIcon: Icon("books.vertical"), titled: "Amaals", to: IbadatView(ibadahType: .amaals))
                    
                    navigationButton(withIcon: Icon("circle.dotted"), titled: "Tasbeeh", to: TasbeehView())
                    navigationButton(withIcon: Icon("safari"), titled: "Qibla", to: QiblaView())
                    navigationButton(withIcon: Icon("dollarsign.circle"), titled: "Donations", to: DonationsView())
                }.padding()
            }
            .scrollIndicators(.hidden)
            .toolbar {
                Toolbar()
            }
        }
    }
    
    private func navigationButton(withIcon icon: Icon, titled title: String, to view: any View, id: UUID = UUID()) -> some View {
        NavigationLink {
            AnyView(view)
                .navigationTransition(.zoom(sourceID: id, in: namespace))
        } label: {
            VStack(spacing: 5) {
                icon
                
                Spacer()
                
                Text(title)
                    .font(.system(.headline, weight: .bold))
                    .singleLine(withAlignment: .center)
            }
            .foregroundStyle(Color.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .secondaryRoundedBackground(cornerRadius: 10)
        }
        .matchedTransitionSource(id: id, in: namespace)
        .padding(2.5)
    }
    
    private struct Icon: View {
        let icon: String
        let mirror: Bool
        
        init(_ icon: String, mirror: Bool = false) {
            self.icon = icon
            self.mirror = mirror
        }
        
        var body: some View {
            HStack(spacing: 0) {
                if mirror {
                    Image(systemName: icon)
                        .scaleEffect(x: -1)
                }
                
                Image(systemName: icon)
            }.font(.title2)
        }
    }
    
    private struct Toolbar: ToolbarContent {
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                favorites
            }
            
            ToolbarItem(placement: .topBarLeading) {
                socials
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                settings
            }
        }
        
        private var favorites: some View {
            NavigationLink {
                
            } label: {
                Image(systemName: "heart")
                    .foregroundStyle(Color.primary)
            }
        }
        
        private var socials: some View {
            NavigationLink {
                
            } label: {
                Image(systemName: "globe")
                    .foregroundStyle(Color.primary)
            }
        }
        
        private var settings: some View {
            NavigationLink {
                
            } label: {
                Image(systemName: "gear")
                    .foregroundStyle(Color.primary)
            }
        }
    }
}

#Preview {
    RootView()
}
