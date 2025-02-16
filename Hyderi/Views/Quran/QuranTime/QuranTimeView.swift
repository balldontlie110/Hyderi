//
//  QuranTimeView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/23/24.
//

import SwiftUI

struct QuranTimeView: View {
    @Environment(\.quranTimes) private var quranTimes
    
    @AppStorage("streak") private var streak: Int = 0
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    streakInfo
                    
                    Divider()
                    
                    if !quranTimes.isEmpty {
                        tabView(proxy)
                        
                        QuranTimeStreakCalendarView()
                    }
                }
            }
        }
    }
    
    private var streakInfo: some View {
        HStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .offset(y: 15)
                .clipped()
                .foregroundStyle(streakColor)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(streak) days")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(streakColor)
                
                if let timeToday {
                    Text("\(timeToday) today")
                        .font(.system(.headline, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }.multilineTextAlignment(.leading)
            
            Spacer()
        }.padding([.horizontal, .top])
    }
    
    private var today: QuranTime? {
        quranTimes.first(where: { Calendar.current.isDateInToday($0.date) })
    }
    
    private var streakColor: Color {
        if let today, today.time > .minimumStreak {
            return Color.streak
        }
        
        return Color(.secondarySystemBackground)
    }
    
    private var timeToday: String? {
        guard let today else { return nil }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        
        return formatter.string(from: TimeInterval(today.time))
    }
    
    private func tabView(_ proxy: GeometryProxy) -> some View {
        TabView {
            Tab {
                VStack(spacing: 10) {
                    QuranTimeWeekView()
                        .secondaryRoundedBackground(cornerRadius: 15)
                    
                    Text("Week")
                        .font(.system(.headline, weight: .bold))
                        .foregroundStyle(Color.secondary)
                        .padding(.bottom, 30)
                }.padding()
            }
            
            Tab {
                VStack(spacing: 10) {
                    QuranTimeLifetimeView()
                        .secondaryRoundedBackground(cornerRadius: 15)
                    
                    Text("Lifetime")
                        .font(.system(.headline, weight: .bold))
                        .foregroundStyle(Color.secondary)
                        .padding(.bottom, 30)
                }.padding()
            }
        }
        .frame(height: proxy.size.height / 2)
        .tabViewStyle(.page)
    }
}

#Preview {
    QuranTimeView()
}
