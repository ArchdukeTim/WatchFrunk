//
//  OpenFrunkButton.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/24/20.
//

import SwiftUI

struct OpenFrunkButton: View {
  let carName: String
  let carId: String
  
  @State var awake = false
  @GestureState var press = false
  
  var body: some View {
    Button(action: {}) {
      Text("\(carName)")
        .gesture(
          LongPressGesture(minimumDuration: 1)
            .updating($press) { currentState, gestureState, transaction in
              gestureState = currentState
            }
            .onEnded { _ in
              openFrunk()
            })
    }
    .background(Color(UIColor(red: 0.91, green: 0.13, blue: 0.15, alpha: 1.00)))
    .foregroundColor(.black)
    .cornerRadius(20)
  }
  
  func openFrunk () {
    var wake_up_counter = 0
    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
      TeslaAPIBridge.sendWakeUp(toVehicle: self.carId) { data, response, error in
        guard let data = data, error == nil else {
          print(error?.localizedDescription ?? "No error")
          return
        }
        let responseJSON = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        if (responseJSON["response"] as! [String: Any])["state"] as! String == "online" {
          TeslaAPIBridge.sendOpenFrunkRequest(toVehicle: carId) { data, response, _ in
            guard let data = data else {
              return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
              print(responseJSON)
            }
            if let response = response as? HTTPURLResponse {
              if response.statusCode == 200 {
                print("Successfully Opened Frunk")
                WKInterfaceDevice.current().play(.success)
                timer.invalidate()
                return
              }
            }
            
            print("Failed to Open Frunk")
            WKInterfaceDevice.current().play(.failure)
          }
        } else {
          wake_up_counter += 1
          if wake_up_counter == 15 {
            timer.invalidate()
          }
        }
      }
    }
  }
}

struct OpenFrunkButton_Previews: PreviewProvider {
  static var previews: some View {
    OpenFrunkButton(carName: "Dragonfly", carId: "1234567910")
    
  }
}
