import SwiftUI
import RealmSwift
struct ChatInterface: View {
    @State var text: String = ""
    @StateObject private var webSocketHandler = WebSocketHandler()
    var id: String = "HFsdf"  // Non-optional id
    @State private var messages: [String] = []  // Keep track of the chat messages
    @FocusState private var isNameFocused: Bool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            
              // Your background image here
            
            VStack {
                Text("Chat With Reporter")
                    .font(.largeTitle)
                    .foregroundStyle(.black.opacity(0.5))
                
                // List of chat messages
                ScrollView {
                    VStack {
                        ForEach(messages, id: \.self) { message in
                            ChatBubble(text: message, isFromCurrentUser: message.contains(id))  // Check if it's from the user or reporter
                        }
                    }
                }
                .onTapGesture {
                    isNameFocused = false
                }
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 360, height: 50)
                    .foregroundStyle(.gray.opacity(0.4))
                    .overlay {
                        HStack {
                            TextField("Chat with reporter", text: $text)
                                .padding()
                                .onSubmit {
                                    sendMessage()
                                }
                            
                            Image(systemName: "paperplane")
                                .onTapGesture {
                                    sendMessage()
                                }
                        }
                    }
            }
            .onAppear {
                // Send the message with the reporter's ID when the chat view appears
                
                do{
                    let realm = try Realm()
                    let storedStuff = realm.objects(RealmModel.self)
                    
                    webSocketHandler.connect()
                    if !storedStuff.isEmpty{
                        webSocketHandler.sendMessage("""
    {"reporter": "\(storedStuff.last?.reporterID ?? "")"}
    """)
                    }
                    // Start listening for incoming messages
                    listenForMessages()
                }catch{
                    print("eror: \(error.localizedDescription)")
                }
               
            }
        }
        
    }
    
    
    // Function to send the message and update the UI
    
    func sendMessage() {
        if !text.isEmpty {
            webSocketHandler.sendMessage("""
            {"chat_message": "\(text)"}
            """)
//            messages.append(text)  // Append the message from the user
            text = ""  // Clear the input field
        }
    }
    
    // Function to listen for incoming messages and update the chat
    func listenForMessages() {
        webSocketHandler.$receivedMessage
            .sink { newMessage in
                if !newMessage.isEmpty {
                    messages.append(String(newMessage))  // Append the new message to the list
                }
            }
            .store(in: &webSocketHandler.cancellables)  // Store the subscriber to avoid memory issues
    }
}
#Preview {
    ChatInterface(id: "")
}
