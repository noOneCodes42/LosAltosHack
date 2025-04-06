//
//  CustomAlertView.swift
//  AI-Music Playlist
//
//  Created by Neel Arora on 4/5/25.
//

import Foundation
import SwiftUI

struct CustomAlert: View {
    var title: String
    var message: String
    @State var disasterAnswer: String = ""
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 300, height: 50)
                .foregroundStyle(Color.gray.opacity(0.2))
                .overlay{
                    TextField("Enter your answer", text: $disasterAnswer)
                        .padding()
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
    CustomAlert(title: "Hi", message: "Hi") {
        print("hi")
    } onCancel: {
        print("hi")
    }

}
