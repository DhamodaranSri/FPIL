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

import Foundation

final class AIAssistantChatService {
    static let shared = AIAssistantChatService()
    private init() {}

    private let systemPrompt = """
    You are FPIL's FireStation Assistant.

    ONLY answer questions about fire safety, fire code compliance, site inspections, remediation cost estimates, QR site scanning, or related fire station workflows.

    If a user asks anything outside fire safety, reply:
    'I can only help with fire station and fire-safety topics. Please contact support for other questions.'

    Keep answers concise and reference regulations when available.
    """

    func sendFireSafetyQuery(_ userText: String) async throws -> String {

//        let apiKey = "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"
        let apiKey = UserDefaultsStore.claudeAPIKey?.claudeKey ?? "" //"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"

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-5",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": userText
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "ClaudeAPI", code: 0)
        }

        let decoded = try JSONDecoder().decode(ClaudeResponse.self, from: data)

        guard let text = decoded.content.first?.text else {
            throw NSError(domain: "ClaudeParsing", code: 0)
        }

        if !responseIsOnTopic(text) {
            return "I can only help with fire station and fire-safety related questions."
        }

        return text
    }

    private func responseIsOnTopic(_ text: String) -> Bool {
        let lower = text.lowercased()

        return lower.contains("fire")
            || lower.contains("sprinkler")
            || lower.contains("extinguisher")
            || lower.contains("violation")
            || lower.contains("alarm")
            || lower.contains("hydrant")
            || lower.contains("code")
    }
}

struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ClaudeContent]
}

struct ClaudeContent: Codable {
    let type: String
    let text: String
}

//final class AIAssistantChatService {
//    static let shared = AIAssistantChatService()
//    private init() {}
//
//    // Strong system prompt to force domain restriction
//    private let systemPrompt = """
//    You are FPIL's FireStation Assistant. ONLY answer questions about fire safety, fire code compliance, site inspections, remediation cost estimates, QR site scanning, or related fire station workflows. \
//    If a user asks anything outside fire safety (medical, legal unrelated, entertainment, politics etc.), politely reply: 'I can only help with fire station and fire-safety topics. Please contact support for other questions.' \
//    Keep answers concise, reference regulations when available, and never invent laws or locations without saying 'I might not be certain — verify with local authority.'
//    """
//    
////    let systemPrompt = """
////    You are an assistant that ONLY answers questions about California fire stations, fire inspections, fire codes, and fire safety regulations.
////
////    If the question is unrelated, respond with:
////    'Sorry, I can only answer California fire station related questions.'
////    """
//    
//    func sendFireSafetyQuery(_ userText: String) async throws -> String {
//
//        let apiKey = "AIzaSyA-RxBELTCehyHuE5_5fa07vxiBzbDJsFo"
//
//        guard let url = URL(string:
//        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)") else {
//            throw URLError(.badURL)
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let body: [String: Any] = [
//            "contents": [
//                [
//                    "parts": [
//                        ["text": systemPrompt + "\nUser: \(userText)"]
//                    ]
//                ]
//            ]
//        ]
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let (data, _) = try await URLSession.shared.data(for: request)
//
//        guard
//            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//            let candidates = json["candidates"] as? [[String: Any]],
//            let content = candidates.first?["content"] as? [String: Any],
//            let parts = content["parts"] as? [[String: Any]],
//            let text = parts.first?["text"] as? String
//        else {
//            throw NSError(domain: "GeminiParsing", code: 0)
//        }
//
//        // Optional domain safety check
//        if !self.responseIsOnTopic(text) {
//            return "I can only help with fire station and fire-safety related questions."
//        }
//
//        return text
//    }
//    private func responseIsOnTopic(_ text: String) -> Bool {
//        let lower = text.lowercased()
//        // Basic heuristic: ensure contains fire-related words or 'fire' at least
//        return lower.contains("fire") || lower.contains("sprinkler") || lower.contains("extinguisher") || lower.contains("violation") || lower.contains("code")
//    }
//}
