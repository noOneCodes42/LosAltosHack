import Foundation
import Combine

class WebSocketHandler: ObservableObject {
    @Published var receivedMessage: String = ""
    @Published var disasterReports: [String] = []  // Keep track of all received disaster reports
    private var webSocketTask: URLSessionWebSocketTask?
    var cancellables: Set<AnyCancellable> = []  // Store subscribers to avoid memory issues
    
    func connect() {
        guard let url = URL(string: "wss://api.thetechtitans.vip") else {
            print("Invalid WebSocket URL")
            return
        }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()  // Start listening for incoming messages
    }
    
    func sendMessage(_ message: String) {
        let messageObj = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(messageObj) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self.receivedMessage = text  // Update UI with the received message
                        self.disasterReports.append(text)  // Append new disaster report to the list
                    }
                    print("Received disaster report: \(text)")
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
            self.receiveMessage()  // Recursively call to keep listening for messages
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
