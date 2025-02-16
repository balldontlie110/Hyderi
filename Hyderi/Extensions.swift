//
//  Extensions.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI
import iCalendarParser

extension View {
    func secondaryRoundedBackground(cornerRadius: CGFloat) -> some View {
        self
            .background {
                Color(.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
    }
    
    func singleLine() -> some View {
        self
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
    
    func onRotate(perform action: @escaping () -> Void) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action()
            }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ conditon: Bool, transform: (Self) -> Content) -> some View {
        if conditon {
            transform(self)
        } else {
            self
        }
    }
}

extension UIApplication {
    @MainActor
    class func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}

extension JSONDecoder {
    static func decode<T: Decodable>(from file: String, to type: T.Type) -> T? {
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else { return nil }
        
        do {
            let data = try Data(contentsOf: URL(filePath: path))
            let result = try JSONDecoder().decode(T.self, from: data)
            
            return result
        } catch {
            print(error)
            
            return nil
        }
    }
}

extension Date {
    func day() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        
        return formatter.string(from: self)
    }
    
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func weekday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: self)
    }
    
    func startOfWeek() -> Date? {
        Calendar.current.dateInterval(of: .weekOfYear, for: self)?.start
    }
    
    func month() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        
        return formatter.string(from: self)
    }
    
    func startOfMonth() -> Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self.startOfDay()))
    }
    
    func year() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        
        return formatter.string(from: self)
    }
    
    func time() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
    
    func date() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        
        return formatter.string(from: self)
    }
    
    func shortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        return formatter.string(from: self)
    }
    
    func extraShortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yy"
        
        return formatter.string(from: self)
    }
    
    func simpleDate() -> String {
        if Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) {
            return self.weekday()
        } else {
            return self.extraShortDate()
        }
    }
    
    func component(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
}

extension ICEvent {
    func weekday(start: Bool = true) -> String? {
        guard let date = date(start: start) else { return nil }
        
        return date.weekday()
    }
    
    func day(start: Bool = true) -> Int? {
        guard let date = date(start: start) else { return nil }
        
        return date.component(.day)
    }
    
    func month(start: Bool = true) -> String? {
        guard let date = date(start: start) else { return nil }
        
        return date.month()
    }
    
    func date(start: Bool = true) -> Date? {
        return start ? self.dtStart?.date : self.dtEnd?.date
    }
}

extension String {
    func cleaned() -> String {
        var string = self
        
        string = string.replacingOccurrences(of: "\\n", with: "\n\n")
        string = string.replacingOccurrences(of: "\\r", with: "\r")
        string = string.replacingOccurrences(of: "\\", with: "")
        
        return string
    }
    
    func date(using format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.defaultDate = Date()
        formatter.dateFormat = "HH:mm"
        
        return formatter.date(from: self)
    }
    
    func lowercasedLetters() -> String {
        return String(unicodeScalars.filter(CharacterSet.letters.contains)).lowercased()
    }
    
    func trimmingWhitespace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String.SubSequence {
    func lowercasedLetters() -> String {
        return String(unicodeScalars.filter(CharacterSet.letters.contains)).lowercased()
    }
}

extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180
    }
    
    var radiansToDegrees: Double {
        return self * 180 / .pi
    }
}

extension EnvironmentValues {
    @Entry var quranTimes: [QuranTime] = []
}
