//
//  AIAssistantViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/11/25.
//

import Foundation
import SwiftUI
import UIKit
import Combine

// Simple message model
struct AIMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isAssistant: Bool
}

@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published var messages: [AIMessage] = [
        AIMessage(text: "Welcome to FPIL!\nI'm your AI-enhanced Fire Safety Assistant. Ask about violations, inspections, QR site scanning...", isAssistant: true)
    ]
    @Published var inputText: String = ""
    @Published var isSending: Bool = false
    @Published var heroImage: UIImage?

    // quick actions
    static let quickActions = ["🔍 Analyze Photo", "📋 Current Violations", "💰 Cost Estimate", "📄 Generate Report"]

    // Replace with your ChatGPT client/service wrapper:
    private let chatService = AIAssistantChatService.shared

    func loadHeroImage(from path: String) {
        if FileManager.default.fileExists(atPath: path),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let img = UIImage(data: data) {
            heroImage = img
        }
    }

    func handleQuickAction(_ action: String) {
        switch action {
        case "🔍 Analyze Photo":
            messages.append(AIMessage(text: "Please upload a photo or open the site camera for analysis.", isAssistant: true))
        case "📋 Current Violations":
            Task { await sendSystemQuery("List current common fire code violations for commercial buildings in India.") }
        case "💰 Cost Estimate":
            messages.append(AIMessage(text: "Provide area, number of violations and rough material costs for estimate.", isAssistant: true))
        case "📄 Generate Report":
            messages.append(AIMessage(text: "I can generate a site inspection summary. Provide site details and findings.", isAssistant: true))
        default:
            break
        }
    }

    func sendMessage() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(AIMessage(text: trimmed, isAssistant: false))
        inputText = ""
        await sendSystemQuery(trimmed)
    }

    private func sendSystemQuery(_ userText: String) async {
        isSending = true
        defer { isSending = false }

        // Step 1: Check if the user asks off-topic (simple local guard)
        if !AIAssistantViewModel.isFireDomainQuery(userText) {
            let reply = "Sorry — I can only answer fire station and fire-safety related questions. If you need general assistance, please contact support."
            messages.append(AIMessage(text: reply, isAssistant: true))
            return
        }

        // Step 2: Ask the chatService to get an assistant reply
        do {
            let responseText = try await chatService.sendFireSafetyQuery(userText)
            messages.append(AIMessage(text: responseText, isAssistant: true))
        } catch {
            messages.append(AIMessage(text: "Failed to get response: \(error.localizedDescription)", isAssistant: true))
        }
    }

    static func isFireDomainQuery(_ text: String) -> Bool {
        // very simple heuristic: keywords relevant to fire safety
        let keywords = ["fire", "violation", "fire extinguisher", "exit", "egress", "sprinkler", "fire hydrant", "code", "inspection", "NFPA", "fire drill", "smoke", "CO2", "fire alarm", "firefighting", "extinguisher", "hosereel", "staircase", "clearance"]
        let lower = text.lowercased()
        let matches = keywords.filter { lower.contains($0) }
        return !matches.isEmpty
    }
}


import Foundation

final class AIAssistantChatService {
    static let shared = AIAssistantChatService()
    private init() {}

    // Strong system prompt to force domain restriction
    private let systemPrompt = """
    You are FPIL's FireStation Assistant. ONLY answer questions about fire safety, fire code compliance, site inspections, remediation cost estimates, QR site scanning, or related fire station workflows. \
    If a user asks anything outside fire safety (medical, legal unrelated, entertainment, politics etc.), politely reply: 'I can only help with fire station and fire-safety topics. Please contact support for other questions.' \
    Keep answers concise, reference regulations when available, and never invent laws or locations without saying 'I might not be certain — verify with local authority.'
    """

    // This function should call the ChatGPT SDK / OpenAI API
    func sendFireSafetyQuery(_ userText: String) async throws -> String {
        // 1. (Optional) Call OpenAI moderation endpoint on userText -> if flagged, reject.
        //    If flagged, return "I cannot assist with that."

        // 2. Build messages: system + user
        let messages = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userText]
        ]
        
        return "Have to implement API call here..."

//        // 3. Call ChatGPT SDK with messages and get response.
//        // PSEUDOCODE: replace with actual SDK call
//        let apiResponse = try await OpenAIChatClient.shared.chat(messages: messages, temperature: 0.2, maxTokens: 800)
//
//        // 4. Post-check: ensure the response is still on-topic (simple check)
//        if !self.responseIsOnTopic(apiResponse) {
//            return "I can only help with fire station and fire-safety related questions. If you need other help, please contact support."
//        }
//
//        // 5. Return assistant reply
//        return apiResponse
    }

    private func responseIsOnTopic(_ text: String) -> Bool {
        let lower = text.lowercased()
        // Basic heuristic: ensure contains fire-related words or 'fire' at least
        return lower.contains("fire") || lower.contains("sprinkler") || lower.contains("extinguisher") || lower.contains("violation") || lower.contains("code")
    }
}
