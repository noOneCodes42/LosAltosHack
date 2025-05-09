import SwiftUI

struct ChatBubble: View {
    let text: String
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }

            Text(text.split(separator: "\"chat_message\":\"")[1].split(separator: "\"")[0].trimmingCharacters(in: .whitespacesAndNewlines))
                .padding(12)
                .foregroundColor(isFromCurrentUser ? .white : .black)
                .background(text.contains("\"reporter\":true") ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .cornerRadius(16)
                .frame(maxWidth: 250, alignment: isFromCurrentUser ? .trailing : .leading)

            if !isFromCurrentUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
