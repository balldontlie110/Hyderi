//
//  IslamicMonth.swift
//  Hyderi
//
//  Created by Ali Earp on 12/7/24.
//

import Foundation

enum IslamicMonth: String, CaseIterable, Encodable {
    case none = ""
    case muharram = "Muharram"
    case safar = "Safar"
    case rabiAlAwwal = "Rabi I"
    case rabiAlThaani = "Rabi' II"
    case jamaadaAlUla = "Jamada I"
    case jamaadaAlThaani = "Jamada II"
    case rajab = "Rajab"
    case shabaan = "Shabban"
    case ramadhan = "Ramadan"
    case shawwal = "Shawaal"
    case dhuAlQadah = "Thi Alqida"
    case dhuAlHijjah = "Thul-Hijja"
    
    init?(monthNumber: Int) {
        guard let islamicMonth = IslamicMonth.allCases.first(where: { $0.number == monthNumber }) else { return nil }
        
        self = islamicMonth
    }
    
    var formatted: String {
        switch self {
        case .none: return ""
        case .muharram: return "Muharram"
        case .safar: return "Safar"
        case .rabiAlAwwal: return "Rabi Al Awwal"
        case .rabiAlThaani: return "Rabi Al Thaani"
        case .jamaadaAlUla: return "Jamaada Al Ula"
        case .jamaadaAlThaani: return "Jamaada Al Thaani"
        case .rajab: return "Rajab"
        case .shabaan: return "Shabaan"
        case .ramadhan: return "Ramadhan"
        case .shawwal: return "Shawwal"
        case .dhuAlQadah: return "Dhu Al Qadah"
        case .dhuAlHijjah: return "Dhu Al Hijjah"
        }
    }
    
    var number: Int {
        switch self {
        case .none: return 0
        case .muharram: return 1
        case .safar: return 2
        case .rabiAlAwwal: return 3
        case .rabiAlThaani: return 4
        case .jamaadaAlUla: return 5
        case .jamaadaAlThaani: return 6
        case .rajab: return 7
        case .shabaan: return 8
        case .ramadhan: return 9
        case .shawwal: return 10
        case .dhuAlQadah: return 11
        case .dhuAlHijjah: return 12
        }
    }
}
