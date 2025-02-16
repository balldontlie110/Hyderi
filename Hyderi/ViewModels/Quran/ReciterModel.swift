//
//  ReciterModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/7/24.
//

import SwiftUI
import ZIPFoundation

class ReciterModel: NSObject, ObservableObject {
    @Published var reciters: [Reciter] = []
    
    @AppStorage("reciterId") var reciterId: Int = 0
    
    @Published var selectedReciter: Reciter?
    
    @Published var progress: Double = 0
    @Published var isDownloading: Bool = false
    @Published var isPaused: Bool = false
    
    @Published var isFinishedDownloading: Bool = false
    
    private var urlSession: URLSession!
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    
    override init() {
        super.init()
        
        loadReciters()
        
        autoDownloadRecitation()
    }
    
    private func loadReciters() {
        guard let reciters = JSONDecoder.decode(from: "Reciters", to: [Reciter].self) else { return }
        
        self.reciters = reciters
    }
    
    private func autoDownloadRecitation() {
        guard reciterId == 0 else { return }
        
        startDownload(from: .alafasyId)
        
        reciterId = .alafasyId
    }
    
    func isRecitationDownloaded(for reciterId: Int) -> Bool {
        guard let reciter = reciters.first(where: { $0.id == reciterId }) else { return false }
        
        let fileManager = FileManager.default
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(reciter.localAsset) else { return false }
        
        return fileManager.fileExists(atPath: fileURL.path())
    }
}

extension Int {
    static let alafasyId = 9
}

extension ReciterModel {
    func configureURLSession() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.Ali.Hyderi.backgroundDownload")
        configuration.timeoutIntervalForResource = 3600
        
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func startDownload(from reciterId: Int) {
        configureURLSession()
        
        guard let reciter = reciters.first(where: { $0.id == reciterId }) else { return }
        
        guard let url = URL(string: "https://everyayah.com/data/\(reciter.url)/000_versebyverse.zip") else { return }
        
        DispatchQueue.main.async {
            self.selectedReciter = reciter
            
            self.isDownloading = true
            self.isPaused = false
            self.progress = 0.0
            
            self.downloadTask = self.urlSession.downloadTask(with: url)
            self.downloadTask?.resume()
        }
    }
        
    func pauseDownload() {
        guard isDownloading, !isPaused else { return }
        
        self.downloadTask?.cancel { data in
            DispatchQueue.main.async {
                self.resumeData = data
                self.isPaused = true
                self.isDownloading = false
            }
        }
    }

    func resumeDownload() {
        guard let resumeData = resumeData, isPaused else { return }
        
        DispatchQueue.main.async {
            self.isPaused = false
            self.isDownloading = true
            
            self.downloadTask = self.urlSession.downloadTask(withResumeData: resumeData)
            self.resumeData = nil
            
            self.downloadTask?.resume()
        }
    }

    func cancelDownload() {
        DispatchQueue.main.async {
            self.downloadTask?.cancel()
            
            self.isDownloading = false
            self.isPaused = false
            self.progress = 0.0
        }
    }
}

extension ReciterModel: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            self.isDownloading = false
            self.isPaused = false
            self.progress = 1.0
        }
        
        let fileManager = FileManager.default
        
        guard let selectedReciter, let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(selectedReciter.localAsset).zip") else { return }
        
        try? fileManager.removeItem(at: destinationURL)
        try? fileManager.moveItem(at: location, to: destinationURL)
        
        guard let extractionURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(selectedReciter.localAsset) else { return }
        
        try? fileManager.removeItem(at: extractionURL)
        try? fileManager.createDirectory(at: extractionURL, withIntermediateDirectories: true)
        
        try? fileManager.unzipItem(at: destinationURL, to: extractionURL)
        
        try? fileManager.removeItem(at: destinationURL)
        
        deletePreviousRecitation()
        
        DispatchQueue.main.async {
            self.isFinishedDownloading = true
        }
    }
    
    private func deletePreviousRecitation() {
        let fileManager = FileManager.default
        
        guard let reciter = reciters.first(where: { $0.id == reciterId }) else { return }
        
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(reciter.localAsset) else { return }
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                completionHandler()
                appDelegate.backgroundSessionCompletionHandler = nil
            }
        }
    }
}
