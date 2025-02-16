//
//  DateSection.swift
//  Hyderi
//
//  Created by Ali Earp on 12/7/24.
//

import SwiftUI

struct DateSection: View {
    let islamicDay: String
    let islamicMonth: IslamicMonth
    let islamicYear: String
    
    let date: Date
    
    init(islamicDay: String, islamicMonth: IslamicMonth, islamicYear: String, date: Date) {
        self.islamicDay = islamicDay
        self.islamicMonth = islamicMonth
        self.islamicYear = islamicYear
        
        self.date = date
    }
    
    init(islamicDate: (islamicDay: Int, islamicMonth: IslamicMonth, islamicYear: Int), date: Date) {
        self.islamicDay = String(islamicDate.islamicDay)
        self.islamicMonth = islamicDate.islamicMonth
        self.islamicYear = String(islamicDate.islamicYear)
        
        self.date = date
    }
    
    var body: some View {
        VStack(spacing: 5) {
            gregorianDate
            
            islamicDate
        }
    }
    
    private var gregorianDate: Text {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        
        return Text(formatter.string(from: date))
            .font(.system(.caption, weight: .bold))
            .foregroundStyle(Color.secondary)
    }
    
    private var islamicDate: Text {
        Text("\(islamicDay) \(islamicMonth.formatted) \(islamicYear)")
            .font(.system(.title2, weight: .bold))
    }
}

#Preview {
    DateSection(islamicDay: "", islamicMonth: .none, islamicYear: "", date: Date())
}
