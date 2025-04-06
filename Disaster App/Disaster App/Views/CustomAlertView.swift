import SwiftUI

struct CustomAlert: View {
    var title: String
    var message: String
    @State var disasterAnswer: String = "" // Local state for user input
    var onConfirm: (String) -> Void        // Pass disasterAnswer back to parent
    var onCancel: () -> Void
    var confirmTitle: String = "OK"
    var cancelTitle: String = "Cancel"

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .foregroundStyle(.black)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .foregroundStyle(.black)
                .font(.body)
                .multilineTextAlignment(.center)

            RoundedRectangle(cornerRadius: 12)
                .frame(width: 300, height: 50)
                .foregroundStyle(Color.gray.opacity(0.5))
                .overlay {
                    TextField("Enter your answer", text: $disasterAnswer)
                        .padding()
                        .textFieldStyle(PlainTextFieldStyle())
                }

            HStack {
                Button(cancelTitle) {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button(confirmTitle) {
                    onConfirm(disasterAnswer) // Pass disasterAnswer to parent
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.black)
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 40)
    }
}

#Preview {
    CustomAlert(title: "Hi", message: "Hi", onConfirm: { answer in
        print("Disaster is \(answer)")
    }, onCancel: {
        print("Cancelled")
    })
}
