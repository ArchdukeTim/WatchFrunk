//
//  TeslaAPIBridge.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/24/20.
//

import Foundation
import KeychainAccess

public class TeslaAPIBridge {
  
  static let client_secret = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"
  static let client_id = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384"
  static let base_url = "https://owner-api.teslamotors.com"
  static let keychain = Keychain(service: "com.archduketim.frunk")
  
  static var authToken: String = ""
  static var refreshToken: String = ""
  
  enum APIError: Error {
    case InvalidCredentials
    case UnknownResponse
  }
  
  /*
   Authorize using email and password
   */
  static func authorize(email: String, password: String, completion: @escaping (String?, String?, Error?) -> Void) {
    let endpoint = "/oauth/token"
    let body: [String: String] = ["email": email,
                                  "password": password,
                                  "client_secret": TeslaAPIBridge.client_secret,
                                  "client_id": TeslaAPIBridge.client_id,
                                  "grant_type": "password"]
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    
    sendRequest(to: TeslaAPIBridge.base_url + endpoint, method: "POST", headers: ["Content-Type": "application/json"], body: jsonData) { data, response, error in
      guard let data = data, error == nil else {
        print(error?.localizedDescription ?? "No error")
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 401 {
          completion(nil, nil, APIError.InvalidCredentials)
          print("Invalid Username / Password")
          return
        }
      }
      let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
      if let responseJSON = responseJSON as? [String: Any] {
        guard let access_token = responseJSON["access_token"] as? String,
              let refresh_token = responseJSON["refresh_token"] as? String else {
          completion(nil, nil, APIError.UnknownResponse)
          return
        }
        completion(access_token, refresh_token, nil)
      }
    }
  }
  
  static func getVehicles(completion: @escaping ([String: String]) -> Void) {
    let endpoint = "/api/1/vehicles"
    let headers = ["Authorization": "Bearer \(authToken)"]
    sendRequest(to: TeslaAPIBridge.base_url + endpoint,
                method: "GET", headers: headers) { data, response, error in
      guard let data = data, error == nil else {
        print(error?.localizedDescription ?? "No error")
        return
      }
      let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
      if let responseJSON = responseJSON as? [String: Any] {
        var cars: [String: String] = [:]
        for car in responseJSON["response"] as! [[String: Any]] {
          cars[car["display_name"] as! String] = (car["id_s"] as! String)
        }
        completion(cars)
      }
    }
  }
  
  /*
   Send a url request
   */
  private static func sendRequest(to url: String, method: String, headers: [String: String] = [:],
                                  body: Data? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = method
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }
    request.httpBody = body
    URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
  }
  
  /*
   Send request to open the frunk
   */
  static func sendOpenFrunkRequest(toVehicle vehicleId: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    let endpoint = "/api/1/vehicles/\(vehicleId)/command/actuate_trunk"
    let body = try? JSONSerialization.data(withJSONObject: ["which_trunk": "front"])
    sendRequest(to: base_url + endpoint,
                method: "POST",
                headers: ["Authorization": "Bearer \(authToken)", "Content-Type": "application/json"],
                body: body,
                completion: completion)
  }
  
  static func sendWakeUp(toVehicle vehicleId: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    let endpoint = "/api/1/vehicles/\(vehicleId)/wake_up"
    let headers = ["Authorization" : "Bearer \(authToken)"]
    sendRequest(to: TeslaAPIBridge.base_url + endpoint,
                method: "POST",
                headers: headers,
                completion: completion)
  }
  
  /*
   Reauthorize authToken using refresh token
   */
  private static func reauthorize(refreshToken: String, ifFailRevoke authToken: String) {
    let json: [String: String] = ["refresh_token": refreshToken,
                                  "client_secret": TeslaAPIBridge.client_secret,
                                  "client_id": TeslaAPIBridge.client_id,
                                  "grant_type": "refresh_token"]
    
    let serialized = try? JSONSerialization.data(withJSONObject: json)
    sendRequest(to: TeslaAPIBridge.base_url + "/oauth/token",
                method: "POST",
                headers: ["Content-Type": "application/json"],
                body: serialized) { data, response, error in
      if let response = response as? HTTPURLResponse {
        if response.statusCode != 200 {
          self.logout() {_, _, _ in
            self.keychain["authToken"] = ""
            self.keychain["refreshToken"] = ""
          }
        }
      }
    }
  }
  /*
   Revoke access token and sign out of app
   */
  static func logout(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    print("Logout Called")
    print(authToken)
    let endpoint = "/oauth/revoke"
    let body = ["token": authToken]
    let json = try? JSONSerialization.data(withJSONObject: body)
    sendRequest(to: TeslaAPIBridge.base_url + endpoint,
                method: "POST",
                headers: ["Content-Type": "application/json"],
                body: json,
                completion: completion)
  }
}
