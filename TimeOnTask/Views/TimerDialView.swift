//
//  TimerDialView.swift
//  TimeOnTask
//

import SwiftUI

struct TimerDialView: View {
    // Shared timer state used to render progress, time, and status text.
    @EnvironmentObject var engine: TimerEngine
    // Diameter of the circular timer dial so the same view can fit window and menu bar layouts.
    var diameter: CGFloat = 220
    // Font size for the central time display.
    var timeFontSize: CGFloat = 44

    // Short status string shown below the countdown.
    private var statusLabel: String {
        switch engine.phase {
        case .idle: return "Ready"
        case .running: return "Remaining"
        case .paused: return "Paused"
        case .complete: return "\(Int(engine.duration / 60)) minutes"
        }
    }

    // Circular progress display with the remaining time in the center.
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 10)

            Circle()
                .trim(from: 0, to: engine.phase == .idle ? 0 : engine.progress)
                .stroke(EmberColor.gradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: EmberColor.accentStart.opacity(engine.phase == .running ? 0.55 : 0), radius: 8)
                .animation(.linear(duration: 0.25), value: engine.progress)

            VStack(spacing: 6) {
                if engine.phase == .complete {
                    Text("Session complete")
                        .font(.system(size: timeFontSize * 0.34, weight: .medium))
                        .multilineTextAlignment(.center)
                } else {
                    Text(engine.formattedRemaining)
                        .font(.system(size: timeFontSize, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                }
                Text(statusLabel)
                    .font(.system(size: 11))
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
        }
        .frame(width: diameter, height: diameter)
    }
}
