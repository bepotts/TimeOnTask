//
//  TimerEngine.swift
//  TimeOnTask
//

import Foundation
import Combine

@MainActor
final class TimerEngine: ObservableObject {
    // Default session length used when a timer engine is created without a custom duration.
    nonisolated static let defaultDuration: TimeInterval = .minutes(30)
    // Preset session lengths shown in the UI for quick timer selection.
    nonisolated static let presets: [TimeInterval] = [
        .minutes(15),
        defaultDuration,
        .minutes(45),
        .minutes(60),
    ]

    // Current lifecycle state that drives the visible controls and timer behavior.
    @Published private(set) var phase: TimerPhase = .idle
    // Amount of time left in the current or selected session.
    @Published private(set) var remaining: TimeInterval
    // Selected session length that idle timers start from.
    @Published var duration: TimeInterval
    // Optional user-entered label used when announcing the completed session.
    @Published var sessionLabel: String = ""

    // Session length captured at start time so progress remains stable during a run.
    private var totalDuration: TimeInterval
    // Wall-clock finish time used to calculate remaining time accurately.
    private var endDate: Date?
    // Repeating timer that refreshes the engine while a session is running.
    private var timer: Timer?

    init(duration: TimeInterval = TimerEngine.defaultDuration) {
        self.duration = duration
        self.totalDuration = duration
        self.remaining = duration
    }

    // Fraction of the active session that has elapsed, used by the circular progress ring.
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return min(1, max(0, 1 - (remaining / totalDuration)))
    }

    // Remaining time formatted for display in the timer views.
    var formattedRemaining: String {
        // Rounded-up whole seconds so the display does not show the next minute too early.
        let total = Int(remaining.rounded(.up))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    func selectPreset(_ seconds: TimeInterval) {
        guard phase == .idle else { return }
        duration = seconds
        remaining = seconds
        totalDuration = seconds
    }

    func start() {
        guard phase == .idle || phase == .paused else { return }
        if phase == .idle {
            totalDuration = duration
            remaining = duration
        }
        phase = .running
        endDate = Date().addingTimeInterval(remaining)
        scheduleTick()
        NotificationManager.shared.requestAuthorizationIfNeeded()
    }

    func pause() {
        guard phase == .running else { return }
        timer?.invalidate()
        timer = nil
        // Captured end date used to convert the paused wall-clock state back into remaining seconds.
        if let endDate {
            remaining = max(0, endDate.timeIntervalSinceNow)
        }
        phase = .paused
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        phase = .idle
        remaining = duration
        totalDuration = duration
    }

    func startAnother() {
        stop()
    }

    private func scheduleTick() {
        timer?.invalidate()
        // Repeating timer that asks the main actor to update remaining time.
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        // Active finish time used to decide whether the session is still running.
        guard let endDate else { return }
        // Current remaining seconds based on the wall clock.
        let remainingNow = endDate.timeIntervalSinceNow
        if remainingNow <= 0 {
            remaining = 0
            complete()
        } else {
            remaining = remainingNow
        }
    }

    private func complete() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        phase = .complete
        NotificationManager.shared.notifySessionComplete(label: sessionLabel, minutes: Int(duration / 60))
    }
}

extension TimerEngine {
    // Preview helper that represents a session that has already finished, without triggering a real notification.
    static func completedPreview() -> TimerEngine {
        let engine = TimerEngine()
        engine.phase = .complete
        engine.remaining = 0
        return engine
    }
}

enum TimerPhase: Equatable {
    case idle
    case running
    case paused
    case complete
}

extension TimeInterval {
    // Converts a whole-minute value into seconds for timer durations.
    nonisolated static func minutes(_ value: Int) -> TimeInterval {
        TimeInterval(value * 60)
    }
}
