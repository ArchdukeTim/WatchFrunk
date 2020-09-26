//
//  Authentication.swift
//  Frunk
//
//  Created by Winters, Tim on 9/22/20.
//

import Foundation
import KeychainAccess


final class UserData: ObservableObject {
  let keychain = Keychain(service: "com.archduketim.frunk")
  
  @Published var vehicles: [String: String] = [:]
  @Published var signedIn: Bool = false
  
  var authToken: String = "" {
    didSet {
      
      keychain["authToken"] = authToken
      TeslaAPIBridge.authToken = authToken
      
      DispatchQueue.main.async {
        if self.authToken == "" {
          self.signedIn = false
        } else {
          self.signedIn = true
          TeslaAPIBridge.getVehicles() { vehicles in
            DispatchQueue.main.async {
              print("Vehicles Got")
            self.vehicles = vehicles
            }
          }
        }
      }
      
    }
  }
  var refreshToken: String = "" {
    didSet {
      keychain["refreshToken"] = refreshToken
      TeslaAPIBridge.refreshToken = refreshToken
    }
  }
  
  init() {
    authToken = keychain["authToken"] ?? ""
    refreshToken = keychain["refreshToken"] ?? ""
    TeslaAPIBridge.authToken = authToken
    TeslaAPIBridge.refreshToken = authToken
    signedIn = authToken != ""
    if signedIn {
      TeslaAPIBridge.getVehicles() { vehicles in
        DispatchQueue.main.async {
          self.vehicles = vehicles
        }
      }
    }
  }
  
  
  
}


