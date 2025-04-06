//
//  ChatInterface.swift
//  Disaster App
//
//  Created by Neel Arora on 4/5/25.
//

import SwiftUI

struct ChatInterface: View {
    @State var text: String = ""
    var body: some View {
        
        ZStack{
            Image("Image")
            VStack{
                Text("Chat With Reporter")
                    .font(.largeTitle)
                    .padding(.bottom, 600)
                    .foregroundStyle(.black.opacity(0.5))
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 360, height: 50)
                    .foregroundStyle(.gray.opacity(0.4))
                    .overlay{
                        TextField("Chat with reporter", text: $text)
                            .padding()
                    }
                

            }
            
        }
    }
}

#Preview {
    ChatInterface()
}
