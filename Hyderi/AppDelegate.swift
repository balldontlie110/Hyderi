//
//  AppDelegate.swift
//  Hyderi
//
//  Created by Ali Earp on 12/6/24.
//

import SwiftUI
import AVFoundation
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        setupPlayback()
        registerNotificationRefresh()
        
        return true
    }
    
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    
    @AppStorage("prayerTimeNotifications") var prayerTimeNotifications: String = "{\"Dawn\": false, \"Sunrise\": false, \"Noon\": false, \"Sunset\": false, \"Maghrib\": false}"
    
    private let backgroundTaskIdentifier = "com.Ali.Hyderi.refresh"
}

extension AppDelegate {
    private func setupPlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print(error)
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
}

extension AppDelegate {
    private func registerNotificationRefresh() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleNotificationRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleNotificationRefresh(task: BGAppRefreshTask) {
        scheduleNotificationRefresh()
        
        PrayerTimeModel.scheduleNotifications(for: prayerTimeNotifications)
        
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleNotificationRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        
        try? BGTaskScheduler.shared.submit(request)
    }
}
