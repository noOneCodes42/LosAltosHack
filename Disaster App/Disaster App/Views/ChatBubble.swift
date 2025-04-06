import SwiftUI

struct ChatBubble: View {
    let text: String
    let isFromCurrentUser: Bool 

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }

            Text(text)
                .padding(12)
                .foregroundColor(isFromCurrentUser ? .white : .black)
                .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(16)
                .frame(maxWidth: 250, alignment: isFromCurrentUser ? .trailing : .leading)

            if !isFromCurrentUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
