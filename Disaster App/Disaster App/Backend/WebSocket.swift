//
//  WebSocket.swift
//  Disaster App
//
//  Created by Neel Arora on 4/5/25.
//

//
//  WebSocket.swift
//  WebSocket
//
//  Created by Neel Arora on 4/5/25.
//

import Foundation

class WebSocketHandler: ObservableObject {
    @Published var receivedMessage: String = ""
    private var webSocketTask: URLSessionWebSocketTask?

    func connect() {
        guard let url = URL(string: "wss://thetechtitans.vip") else {
            print("Invalid WebSocket URL")
            return
        }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage() // Start listening for incoming messages
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
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.receivedMessage = text
                    }
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    print("Unknown message type")
                }
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
            self?.receiveMessage() // Continue listening for messages
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

