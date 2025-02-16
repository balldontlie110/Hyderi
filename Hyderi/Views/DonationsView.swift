//
//  DonationsView.swift
//  Hyderi
//
//  Created by Ali Earp on 12/2/24.
//

import SwiftUI
import StripePaymentSheet
import WStack

struct DonationsView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject private var donationsModel: DonationsModel = DonationsModel()
    
    var body: some View {
        ZStack {
            Button {
                hideKeyboard()
            } label: {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack(spacing: 20) {
                donationBox
                
                donationPresets
                
                Spacer()
                
                if donationsModel.loading {
                    ProgressView()
                }
                
                Spacer()
                
                donateButton
            }
            .padding()
            .padding(.vertical)
        }
        .safeAreaPadding(.bottom, !audioPlayer.forceAudioSlider ? 0 : 75)
        .paymentSheet(isPresented: $donationsModel.showPaymentSheet, paymentSheet: donationsModel.paymentSheet) { _ in }
        .navigationTitle("Donations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }
    
    private var donationBox: some View {
        HStack {
            Text("£")
            
            TextField("", text: amount)
                .keyboardType(.numberPad)
        }
        .font(.system(.headline, weight: .bold))
        .padding(10)
        .secondaryRoundedBackground(cornerRadius: 10)
    }
    
    private var amount: Binding<String> {
        Binding {
            String(donationsModel.amount)
        } set: { value in
            guard let amount = Int(value.filter({ $0.isNumber })) else { return }
            
            donationsModel.amount = amount
        }
    }
    
    private let presetAmounts = [10, 25, 50, 100, 250]
    
    private var donationPresets: some View {
        WStack(presetAmounts, alignment: .center) { amount in
            Button {
                donationsModel.amount = amount
            } label: {
                Text("£\(amount)")
                    .padding(.vertical, 5)
                    .frame(width: 75)
            }.buttonStyle(BorderedButtonStyle())
        }
    }
    
    private var donateButton: some View {
        Button {
            donationsModel.prepareDonationSheet()
        } label: {
            Text("Donate")
        }
        .buttonStyle(DefaultButtonStyle())
        .padding()
    }
}

#Preview {
    DonationsView()
}
