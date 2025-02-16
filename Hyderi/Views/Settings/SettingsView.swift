//
//  SettingsView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/11/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var reciterModel: ReciterModel = ReciterModel()
    
    @StateObject var quranModel: QuranModel
    @StateObject var prayerTimeModel: PrayerTimeModel
    
    @State private var showReciterPicker: Bool = false
    @State private var showTranslatorPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    HStack(alignment: .top, spacing: 50) {
                        translatorCard
                        
                        reciterCard
                    }.padding()
                    
                    prayerTimeNotifications
                    
                    AuthenticationView()
                        .padding(.vertical)
                }.padding()
            }
            .sheet(isPresented: $showTranslatorPicker) {
                TranslatorPicker(quranModel: quranModel, showTranslatorPicker: $showTranslatorPicker)
            }
            .sheet(isPresented: $showReciterPicker) {
                ReciterPicker(reciterModel: reciterModel, showReciterPicker: $showReciterPicker)
            }
            .navigationTitle("Settings")
        }
    }
    
    @ViewBuilder
    private var translatorCard: some View {
        if let translator = quranModel.translators.first(where: { $0.id == quranModel.translatorId }) {
            Button {
                showTranslatorPicker.toggle()
            } label: {
                TranslatorCard(translator: translator)
            }
        }
    }
    
    @ViewBuilder
    private var reciterCard: some View {
        if let reciter = reciterModel.reciters.first(where: { $0.id == reciterModel.reciterId }) {
            Button {
                showReciterPicker.toggle()
            } label: {
                ReciterCard(reciter: reciter)
            }
        }
    }
    
    private var prayerTimeNotifications: some View {
        ForEach(prayerTimeModel.prayerTimeNotifications.sorted(by: { $0.key < $1.key }), id: \.key) { (prayer, active) in
            Toggle(isOn: prayerTimeNotificationBinding(prayer, active)) {
                HStack(spacing: 10) {
                    Text(prayer.emoji)
                    
                    Text(prayer.formatted)
                        .bold()
                }
            }
        }
    }
    
    private func prayerTimeNotificationBinding(_ prayer: Prayer, _ active: Bool) -> Binding<Bool> {
        Binding(get: {
            active
        }, set: { newValue in
            prayerTimeModel.prayerTimeNotifications[prayer] = newValue
        })
    }
}

#Preview {
    SettingsView(quranModel: QuranModel(), prayerTimeModel: PrayerTimeModel())
}
