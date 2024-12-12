//
//  Order.swift
//  CupcakeCorner
//
//  Created by Jasper Tan on 12/10/24.
//

import SwiftUI


@Observable
class Order: Codable {
    
    struct UserAddress: Codable {
        var name: String = ""
        var streetAddress: String = ""
        var city: String = ""
        var zip: String = ""
    }
    
    
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _userAddress = "userAddress"
//        case _name = "name"
//        case _city = "city"
//        case _streetAddress = "streetAddress"
//        case _zip = "zip"
    }
    
    init() {
        if let savedAddress = UserDefaults.standard.data(forKey: "userAddress") {
            if let decoded = try? JSONDecoder().decode(UserAddress.self, from: savedAddress) {
                userAddress = decoded
                return
            }
        }
        
        userAddress = UserAddress()
    }
    
    
    
    /* Cupcake types & selection*/
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    var type = 0
    
    /* Quantity */
    var quantity = 3
    
    
    /* Special requests */
    var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    var extraFrosting = false
    var addSprinkles = false
    
    
    
    
    
    
    // Address properties
    var userAddress: UserAddress {
        didSet {
            if let encoded = try? JSONEncoder().encode(userAddress) {
                UserDefaults.standard.set(encoded, forKey: "userAddress")
            }
        }
    }

    
    // Determines if address is valid
    var hasValidAddress: Bool {
        if userAddress.name.isEmpty || userAddress.streetAddress.isEmpty || userAddress.city.isEmpty || userAddress.zip.isEmpty {
            return false
        }
        
        if (userAddress.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            userAddress.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            userAddress.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            userAddress.zip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        {
            return false
        }
        
        return true
    }
    
    // Determines cost of order
    var cost: Decimal {
        
        // 2 per cupcake
        var cost = Decimal(quantity) * 2
        
        // complicated cakes cost more
        cost += Decimal(type) / 2
        
        // $1 per cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // .50 per cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
    
}
