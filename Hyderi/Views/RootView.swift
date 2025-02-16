//
//  RootView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI
import WStack

struct RootView: View {
    @StateObject private var quranModel: QuranModel = QuranModel()
    @StateObject private var calendarModel: CalendarModel = CalendarModel()
    @StateObject private var prayerTimeModel: PrayerTimeModel = PrayerTimeModel()
    
    @Namespace private var namespace
    
    private let navigationColumns: [GridItem] = [GridItem](repeating: GridItem(.flexible()), count: 3)
    
    @State private var showSocials: Bool = false
    @State private var showQuranTime: Bool = false
    @State private var showSettings: Bool = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \QuranTime.date, ascending: true)], animation: .default)
    private var quranTimes: FetchedResults<QuranTime>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PrayerDay.date, ascending: true)], animation: .default)
    private var prayerDays: FetchedResults<PrayerDay>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    DateSection(islamicDay: calendarModel.islamicDay, islamicMonth: calendarModel.islamicMonth, islamicYear: calendarModel.islamicYear, date: Date())
                    
                    PrayerTimesView(prayerTimes: prayerTimes)
                    
                    LazyVGrid(columns: navigationColumns) {
                        navigationButton(withIcon: Icon("book"), titled: "Quran", to: QuranView())
                        navigationButton(withIcon: Icon("calendar"), titled: "Calendar", to: CalendarView(calendarModel: calendarModel, prayerTimeModel: prayerTimeModel))
                        navigationButton(withIcon: Icon("list.bullet"), titled: "Events", to: EventsView())
                        
                        navigationButton(withIcon: Icon("hand.raised", mirror: true), titled: "Du'as", to: IbadatView(quranModel: quranModel, ibadahType: .duas))
                        navigationButton(withIcon: Icon("moon.dust"), titled: "Ziaraah", to: IbadatView(quranModel: quranModel, ibadahType: .ziaraah))
                        navigationButton(withIcon: Icon("books.vertical"), titled: "Amaals", to: IbadatView(quranModel: quranModel, ibadahType: .amaals))
                        
                        navigationButton(withIcon: Icon("music.microphone"), titled: "Nasheeds", to: IbadatView(quranModel: quranModel, ibadahType: .nasheeds))
                        navigationButton(withIcon: Icon("circle.dotted"), titled: "Tasbeeh", to: TasbeehView())
                        navigationButton(withIcon: Icon("location.north"), titled: "Qibla", to: QiblaView())
                        
                        Spacer()
                        
                        navigationButton(withIcon: Icon("gift"), titled: "Donations", to: DonationsView())
                        
                        Spacer()
                    }
                }.padding()
            }
            .scrollIndicators(.hidden)
            .toolbar {
                Toolbar(showSocials: $showSocials, showQuranTime: $showQuranTime, showSettings: $showSettings)
            }
        }
        .sheet(isPresented: $showSocials) {
            SocialsView()
        }
        .sheet(isPresented: $showQuranTime) {
            QuranTimeView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(quranModel: quranModel, prayerTimeModel: prayerTimeModel)
        }
        .onAppear {
            QuranTimeModel.updateStreak(quranTimes: Array(quranTimes))
        }
        .environment(\.quranTimes, Array(quranTimes))
        .environmentObject(quranModel)
    }
    
    private var prayerTimes: [Prayer : Date] {
        PrayerTimeModel.prayerTimes(on: Date(), from: prayerTimeModel.prayerTimes)
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
                    .singleLine()
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
            HStack(spacing: -5) {
                if mirror {
                    Image(systemName: icon)
                        .scaleEffect(x: -1)
                }
                
                Image(systemName: icon)
            }.font(.title2)
        }
    }
    
    private struct Toolbar: ToolbarContent {
        @Binding var showSocials: Bool
        @Binding var showQuranTime: Bool
        @Binding var showSettings: Bool
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                socials
            }
            
            ToolbarItem(placement: .topBarLeading) {
                quranTime
            }
            
            ToolbarItem(placement: .topBarLeading) {
                prayerStreak
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                settings
            }
        }
        
        private var socials: some View {
            Button {
                showSocials.toggle()
            } label: {
                Image(systemName: "globe")
                    .foregroundStyle(Color.primary)
            }
        }
        
        private var quranTime: some View {
            Button {
                showQuranTime.toggle()
            } label: {
                Image(systemName: "flame")
                    .foregroundStyle(Color.primary)
            }
        }
        
        private var prayerStreak: some View {
            NavigationLink {
                PrayerStreakView()
            } label: {
                Image(systemName: "clock")
                    .foregroundStyle(Color.primary)
            }
        }
        
        private var settings: some View {
            Button {
                showSettings.toggle()
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
