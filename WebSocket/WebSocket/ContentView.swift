//
//  ContentView.swift
//  WebSocket
//
//  Created by Neel Arora on 4/5/25.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var webSocketHandler = WebSocketHandler()
    @State private var inputMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Received Message:")
                .font(.headline)
            Text(webSocketHandler.receivedMessage)
                .foregroundColor(.blue)

            TextField("Enter your message", text: $inputMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Send Message") {
                webSocketHandler.sendMessage(inputMessage)
            }
            .buttonStyle(.borderedProminent)

            Button("Connect") {
                webSocketHandler.connect()
            }
            .buttonStyle(.bordered)

            Button("Disconnect") {
                webSocketHandler.disconnect()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
