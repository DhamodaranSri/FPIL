//
//  TimerView.swift
//  FPIL
//
//  Created by OrganicFarmers on 13/10/25.
//

import SwiftUI

struct TimerView: View {
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    let isRunning: Bool
    let startTime: TimeInterval?

    var body: some View {
        Text(formattedTime)
            .font(ApplicationFont.bold(size: 20).value)
            .foregroundColor(.white)
            .onAppear {
                if let startTime = startTime {
                    elapsedTime = startTime
                }
                if isRunning {
                    startTimer()
                }
            }
            .onChange(of: isRunning) { running in
                if running {
                    startTimer()
                } else {
                    stopTimer()
                }
            }
            .onDisappear {
                stopTimer()
            }
    }

    private var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime.truncatingRemainder(dividingBy: 3600)) / 60
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

