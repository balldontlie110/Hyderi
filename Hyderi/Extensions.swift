//
//  Extensions.swift
//  Hyderi
//
//  Created by Ali Earp on 12/1/24.
//

import SwiftUI

extension View {
    func secondaryRoundedBackground(cornerRadius: CGFloat) -> some View {
        self
            .background {
                Color(.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
    }
    
    func singleLine(withAlignment alignment: TextAlignment) -> some View {
        self
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(alignment)
    }
    
    func onRotate(perform action: @escaping () -> Void) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action()
            }
    }
}

extension JSONDecoder {
    func decode<T: Decodable>(from file: String, to type: T.Type) -> T? {
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else { return nil }
        
        do {
            let data = try Data(contentsOf: URL(filePath: path))
            let result = try self.decode(T.self, from: data)
            
            return result
        } catch {
            print(error)
            
            return nil
        }
    }
}
