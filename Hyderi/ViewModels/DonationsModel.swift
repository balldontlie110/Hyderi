//
//  DonationsModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/22/24.
//

import Foundation
import StripePaymentSheet

class DonationsModel: ObservableObject {
    @Published var paymentSheet: PaymentSheet = PaymentSheet(setupIntentClientSecret: "", configuration: PaymentSheet.Configuration())
    @Published var showPaymentSheet: Bool = false
    
    @Published var loading: Bool = false
    
    @Published var amount: Int = 10
    
    func prepareDonationSheet() {
        self.loading = true
        
        guard let url = URL(string: "https://mewing-bittersweet-mousepad.glitch.me/donations-sheet") else {
            self.loading = false
            
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(Donation(amount: amount))
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil, let data else {
                DispatchQueue.main.async { self.loading = false }
                
                return
            }
            
            do {
                let donationResponse = try JSONDecoder().decode(DonationResponse.self, from: data)
                
                STPAPIClient.shared.publishableKey = donationResponse.publishableKey
                
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Hyderi"
                configuration.customer = PaymentSheet.CustomerConfiguration(id: donationResponse.customer, ephemeralKeySecret: donationResponse.ephemeralKey)
                
                AuthenticationModel.authenticate(withReason: "To make sure it's really you when making donations.") { success in
                    if success {
                        self.paymentSheet = PaymentSheet(paymentIntentClientSecret: donationResponse.paymentIntent, configuration: configuration)
                        self.showPaymentSheet = true
                    }
                    
                    DispatchQueue.main.async { self.loading = false }
                }
            } catch {
                DispatchQueue.main.async { self.loading = false }
                
                print(error)
            }
        }.resume()
    }
}
