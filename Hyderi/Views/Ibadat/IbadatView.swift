//
//  IbadatView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/3/24.
//

import SwiftUI

struct IbadatView: View {
    let ibadahType: IbadahType
    
    enum IbadahType {
        case duas, ziaraah, amaals
        
        var ibadat: [Ibadah] {
            switch self {
            case .duas:
                return DuaModel().duas
            case .ziaraah:
                return ZiyaratModel().ziaraah
            case .amaals:
                return AmaalModel().amaals
            }
        }
        
        func view<I: Ibadah>(for ibadah: I) -> any View {
            switch self {
            case .duas:
                if let dua = ibadah as? Dua {
                    return DuaView(dua: dua)
                }
            case .ziaraah:
                if let ziyarat = ibadah as? Ziyarat {
                    return ZiyaratView(ziyarat: ziyarat)
                }
            case .amaals:
                if let amaal = ibadah as? Amaal {
                    return AmaalView(amaal: amaal)
                }
            }
            
            return EmptyView()
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(ibadahType.ibadat, id: \.id) { ibadah in
                    NavigationLink {
                        AnyView(ibadahType.view(for: ibadah))
                    } label: {
                        IbadahCard(ibadah: ibadah)
                    }
                }
            }.padding(10)
        }
    }
    
    struct IbadahCard: View {
        let ibadah: Ibadah
        
        var body: some View {
            HStack(spacing: 10) {
                ZStack {
                    Image(systemName: "diamond")
                        .font(.system(size: 40, weight: .ultraLight))
                    
                    Text(String(ibadah.id))
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Text(ibadah.title)
                        .font(.system(.headline, weight: .bold))
                    
                    if let subtitle = ibadah.subtitle {
                        Text(subtitle)
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Spacer()
            }
            .foregroundStyle(Color.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding([.vertical, .trailing], 15)
            .padding(.leading, 10)
            .secondaryRoundedBackground(cornerRadius: 5)
        }
    }
}

protocol Ibadah {
    var id: Int{ get }
    var title: String { get }
    var subtitle: String? { get }
}

#Preview {
    IbadatView(ibadahType: .duas)
}
