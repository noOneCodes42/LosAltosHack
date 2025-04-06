//
//  LocationIncidentReporter.swift
//  Disaster App
//
//  Created by Neel Arora on 4/5/25.
//

import Foundation
import Combine

class LocationIncidentReporter: ObservableObject {
    @Published var responseMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let retryAttempts = 3
    private let timeoutInterval: TimeInterval = 30 // Timeout after 30 seconds
    
    func createUser(user: IncidentModelSend) {
        
        guard let url = URL(string: "https://api.thetechtitans.vip/incident/receive") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(user)
        } catch {
            self.errorMessage = "Failed to encode user data: \(error.localizedDescription)"
            return
        }
        //https://thetechtitans.vip/incident/[id]
        
        performRequest(request: request, retryCount: retryAttempts)
    }
    
    private func performRequest(request: URLRequest, retryCount: Int) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

   

                // Handle network errors
                if let error = error as? URLError {
                    if retryCount > 0 && error.code == .networkConnectionLost {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Retry after 2 seconds
                            self.performRequest(request: request, retryCount: retryCount - 1)
                        }
                        return
                    }
                    
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                // Ensure there is a valid HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "No HTTP response received"
                    print("No HTTP response received")
                    return
                }
                
                // Check for HTTP status code errors
                if httpResponse.statusCode != 400 {
                    self.errorMessage = "HTTP Error \(httpResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    print("HTTP Error \(httpResponse.statusCode)")
                    
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Raw response:", responseString)
                    }
                    
                    return
                }
                
                // Ensure there is data in the response
                guard let data = data else {
                    self.errorMessage = "No data received"
                    print("No data received")
                    return
                }
                
                // Log raw response for debugging
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to convert data"
                print("Raw response body: \(responseString)")
                
                // Attempt to decode JSON response into expected model
                do {
                    let jsonDecoder = JSONDecoder()
                    
                    // Decode the JSON into the expected model
                    let responseModel = try jsonDecoder.decode(IncidentModelRecieve.self, from: data)
                    self.responseMessage = responseModel.disaster

                    print("Received message from server: \(self.responseMessage)")
                    
                } catch let decodingError {
                    // Handle decoding errors gracefully and log raw response for debugging
                    self.errorMessage = "Error decoding JSON: \(decodingError.localizedDescription)"
                    print("Error decoding JSON: \(decodingError.localizedDescription)")
                    
                    // Log raw response again for debugging purposes
                    print("Raw response body (for debugging): \(responseString)")
                    
                    // Additional fallback for malformed JSON (if needed)
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                        print("Fallback JSON object parsing succeeded:")
                        print(jsonObject)
                    } else {
                        print("Fallback JSON object parsing failed.")
                    }
                }
            }
        }.resume()
    }
}

