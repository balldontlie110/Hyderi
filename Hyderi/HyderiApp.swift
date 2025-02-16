//
//  HyderiApp.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI
import Stripe
import WidgetKit
import FirebaseCore

@main
struct HyderiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var audioPlayer: AudioPlayer = AudioPlayer()
    
    @AppStorage("prayerTimeNotifications") var prayerTimeNotifications: String = "{\"Dawn\": false, \"Sunrise\": false, \"Noon\": false, \"Sunset\": false, \"Maghrib\": false}"
    
    init() {
        StripeAPI.defaultPublishableKey = "pk_test_51Pe4tQ2MMIgwRw7skabvi1bZLAmJBVMG8T5PYugUmLp9giwIaY5IjfK8XfPVI1tUh98MSbcIt49Fh7mBp5HatF9I008DVb0UWm"
        
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
                .environmentObject(audioPlayer)
                .overlay(alignment: .bottom) { AudioSlider(audioPlayer: audioPlayer) }
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                    
                    PrayerTimeModel.scheduleNotifications(for: prayerTimeNotifications)
                }
        }
    }
}
