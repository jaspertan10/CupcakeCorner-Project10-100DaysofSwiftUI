//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Jasper Tan on 12/10/24.
//

import SwiftUI

struct CheckoutView: View {
    
    var order: Order
    
    //Alert for place order confirmation
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    
    //Alert for place order failure
    @State private var errorMessage = ""
    @State private var showError = false
    
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total is \(order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }

            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank you!", isPresented: $showingConfirmation) {
            Button("OK") {}
        } message: {
            Text(confirmationMessage)
        }
        .alert("Error!", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    func placeOrder() async {
        
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "Your order for \(decodedOrder.quantity) x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
            showingConfirmation = true
            } catch {
                errorMessage = "Checkout failed: \(error.localizedDescription)"
                showError = true
                print("Checkout failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CheckoutView(order: Order())
}
