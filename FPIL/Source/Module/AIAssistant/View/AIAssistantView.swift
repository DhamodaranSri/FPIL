//
//  AIAssistantView.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/11/25.
//

import SwiftUI

struct AIAssistantView: View {
    @StateObject private var vm = AIAssistantViewModel()
   // @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Chat bubbles / content area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        // (Optional) show uploaded screenshot as a hero image
                        if let hero = vm.heroImage {
                            Image(uiImage: hero)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 180)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }

                        // Conversation
                        ForEach(vm.messages) { msg in
                            HStack {
                                if msg.isAssistant { Spacer() }
                                ChatBubbleView(text: msg.text, isAssistant: msg.isAssistant)
                                    .id(msg.id)
                                if !msg.isAssistant { Spacer() }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGray6))
                .onChange(of: vm.messages.count) { _ in
                    // scroll to last
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // Quick actions chips
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(AIAssistantViewModel.quickActions, id: \.self) { action in
//                        Button(action: { vm.handleQuickAction(action) }) {
//                            HStack(spacing: 8) {
//                                Text(action)
//                            }
//                            .padding(.horizontal, 14)
//                            .padding(.vertical, 10)
//                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray5)))
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 8)
//            }

            // Input field
            HStack(spacing: 12) {
                TextField("Ask about violations, codes, or get AI help…", text: $vm.inputText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray5)))
                    .disableAutocorrection(true)

                Button(action: {
                    Task { await vm.sendMessage() }
                }) {
                    Text("Send")
                        .bold()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 6)
        .onAppear { }
    }
}

struct ChatBubbleView: View {
    let text: String
    let isAssistant: Bool

    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.white)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isAssistant ? Color(.darkGray) : Color(.systemBlue))
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.78, alignment: .leading)
    }
}

// cornerRadius helper
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = 12.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

