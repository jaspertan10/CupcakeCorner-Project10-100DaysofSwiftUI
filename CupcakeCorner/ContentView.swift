//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Jasper Tan on 12/9/24.
//

import SwiftUI
import CoreHaptics


struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

@Observable
class User: Codable {
    
    enum CodingKeys: String, CodingKey {
            case _name = "name"
        }
    
    var name = "Taylor"
}



struct SandboxView: View {
    
    @State private var results: [Result] = []
    
    @State private var username = ""
    @State private var email = ""
    
    
    var disableForm: Bool {
        username.count < 5 || email.count < 5
    }
    
    func encodeTaylor() {
        let data = try! JSONEncoder().encode(User())
        let str = String(decoding:data, as: UTF8.self)
        print(str)
    }
    
    var body: some View {
        
        Button("Encode Taylor", action: encodeTaylor)
        
        
        /*
        Form {
            Section {
                TextField("Username", text: $username)
                TextField("Password", text: $username)
            }
            
            Section {
                Button("Create Account") {
                    print("Creating account...")
                }
                .disabled(disableForm)
            }
        } */
        
        
        
        /*
        VStack {
            
//            AsyncImage(url: URL(string: "https://hws.dev/img/logo.png")) { image in
//                image
//                    .resizable()
//                    .scaledToFit()
//            } placeholder: {
//                //Color.red
//                ProgressView()
//            }
//            .frame(width: 200, height: 200)
            
            AsyncImage(url: URL(string: "https://hws.dev/img/bad.png")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                }
                else if phase.error != nil {
                    Text("There is an error loading the image")
                }
                else {
                    ProgressView()
                }
            }
            
            List(results, id: \.trackId) { item in
                VStack(alignment: .leading) {
                    Text(item.trackName)
                        .font(.headline)
                    Text(item.collectionName)
                }
            }
            .task {
                await loadData()
            }
        } */
        
        
    }
    
    func loadData() async {
        
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=song") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedResponse.results
            }
        } catch {
            print("Invalid data")
        }
    }
}




struct ContentView: View {
    
    @State private var counter: [Int] = Array(repeating: 0, count: 8)
    @State private var engine: CHHapticEngine?
    
    var body: some View {

        VStack(spacing: 20) {
            Button(".increase \(counter[0])") {
                counter[0] += 1
            }
            .sensoryFeedback(.increase, trigger: counter[0])
            
            Button(".success: \(counter[1])") {
                counter[1] += 1
            }
            .sensoryFeedback(.success, trigger: counter[1])
            
            Button(".warning: \(counter[2])") {
                counter[2] += 1
            }
            .sensoryFeedback(.warning, trigger: counter[2])
            
            Button(".error: \(counter[3])") {
                counter[3] += 1
            }
            .sensoryFeedback(.error, trigger: counter[3])
            
            Button(".start: \(counter[4])") {
                counter[4] += 1
            }
            .sensoryFeedback(.start, trigger: counter[4])
            
            Button(".stop: \(counter[5])") {
                counter[5] += 1
            }
            .sensoryFeedback(.stop, trigger: counter[5])
            
            Button("flex soft") {
                counter[6] += 1
            }
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: counter[6])
            
            Button("weight heavy") {
                counter[7] += 1
            }
            .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: counter[7])
            
            Button("Haptic from CoreHaptics") {
                complexSuccess()
            }
            .onAppear(perform: prepareHaptics)
        }
        
    }
    
    func prepareHaptics() {
        //Ensure device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    
    func complexSuccess() {
        //Ensure device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        var events: [CHHapticEvent] = []
        
//        //Create one intense, sharp tap
//        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
//        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
//        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
//        events.append(event)
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }

        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1 + i)
            events.append(event)
        }
        
        //convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}

#Preview {
    //SandboxView()
    ContentView()
}
