//
//  Donation.swift
//  Hyderi
//
//  Created by Ali Earp on 12/22/24.
//

import Foundation

struct Donation: Encodable {
    let amount: Int
}

struct DonationResponse: Decodable {
    let paymentIntent: String
    let ephemeralKey: String
    let customer: String
    let publishableKey: String
}
