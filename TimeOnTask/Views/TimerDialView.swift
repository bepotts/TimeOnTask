//
//  TimerDialView.swift
//  TimeOnTask
//

import SwiftUI
import AppKit

struct TimerDialView: View {
    // Shared timer state used to render progress, time, and status text.
    @EnvironmentObject var engine: TimerEngine
    // Diameter of the circular timer dial so the same view can fit window and menu bar layouts.
    var diameter: CGFloat = 220
    // Font size for the central time display.
    var timeFontSize: CGFloat = 44
    // Called after the fourth digit is entered so the containing view can move focus to its primary control.
    var onCompletedDigitEntry: () -> Void = {}

    // Whether the time display is currently showing its editable digit boxes.
    @State private var isEditingTime = false
    // Single-character contents of the four digit boxes: minutes tens, minutes ones, seconds tens, seconds ones.
    @State private var digits: [String] = ["", "", "", ""]
    @FocusState private var focusedDigitIndex: Int?

    // Time can only be hand-edited when the timer isn't actively counting down.
    private var isTimeEditable: Bool {
        engine.phase == .idle || engine.phase == .paused
    }

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
                } else if isEditingTime {
                    HStack(spacing: 4) {
                        digitBox(0)
                        digitBox(1)
                        Text(":")
                            .font(.system(size: timeFontSize * 0.7, weight: .medium, design: .monospaced))
                        digitBox(2)
                        digitBox(3)
                    }
                    .onChange(of: focusedDigitIndex) { _, focused in
                        if focused == nil { commitEdit() }
                    }
                } else {
                    Text(engine.formattedRemaining)
                        .font(.system(size: timeFontSize, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                        .contentShape(Rectangle())
                        .onTapGesture { beginEditing() }
                        .onHover { hovering in
                            guard isTimeEditable else { return }
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
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

    // A single-digit entry box used to build up the MM:SS display.
    private func digitBox(_ index: Int) -> some View {
        TextField("", text: digitBinding(index))
            .font(.system(size: timeFontSize * 0.82, weight: .medium, design: .monospaced))
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .frame(width: timeFontSize * 0.62, height: timeFontSize * 1.05)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(focusedDigitIndex == index ? 0.35 : 0.12), lineWidth: 1.5)
            )
            .contentShape(Rectangle())
            .focused($focusedDigitIndex, equals: index)
            .onTapGesture { focusedDigitIndex = index }
            .onSubmit { commitEdit() }
            .onKeyPress { press in
                guard let typed = press.characters.last else {
                    return .ignored
                }
                guard typed.isASCII, typed.isNumber else {
                    return .handled
                }
                setDigitFromKeystroke(typed, at: index)
                return .handled
            }
            .onKeyPress(.delete) {
                guard digits[index].isEmpty else { return .ignored }
                moveFocusBackward(from: index)
                return .handled
            }
    }

    // Binding that filters each box down to a single digit and advances focus once filled.
    private func digitBinding(_ index: Int) -> Binding<String> {
        Binding(
            get: { digits[index] },
            set: { newValue in setDigit(newValue, at: index) }
        )
    }

    // Handles physical digit keys directly so typing over a prefilled box still advances immediately.
    private func setDigitFromKeystroke(_ typed: Character, at index: Int) {
        digits[index] = String(typed)
        advanceFocus(from: index)
    }

    // Accepts only a genuinely typed digit (replacing whatever was there) and advances; any other keystroke,
    // letters included, is ignored outright so the box's contents never change because of it.
    private func setDigit(_ newValue: String, at index: Int) {
        let old = digits[index]
        guard newValue.count > old.count, let typed = newValue.last else {
            // Deletion (or no net growth): keep only digits, dropping anything non-numeric.
            digits[index] = String(newValue.filter { $0.isASCII && $0.isNumber }.suffix(1))
            return
        }
        guard typed.isASCII, typed.isNumber else { return }
        digits[index] = String(typed)
        advanceFocus(from: index)
    }

    private func advanceFocus(from index: Int) {
        guard index < digits.count - 1 else {
            commitEdit()
            DispatchQueue.main.async {
                onCompletedDigitEntry()
            }
            return
        }
        let nextIndex = index + 1
        DispatchQueue.main.async {
            focusedDigitIndex = nextIndex
        }
    }

    // Backspacing on an already-empty box hops back and clears the previous one, like standard OTP inputs.
    private func moveFocusBackward(from index: Int) {
        guard index > 0 else { return }
        digits[index - 1] = ""
        focusedDigitIndex = index - 1
    }

    // Switches the time display into four editable digit boxes pre-filled with the current time.
    private func beginEditing() {
        guard isTimeEditable else { return }
        let total = Int(engine.remaining.rounded())
        let minutes = min(99, total / 60)
        let seconds = total % 60
        digits = [
            String(minutes / 10),
            String(minutes % 10),
            String(seconds / 10),
            String(seconds % 10),
        ]
        isEditingTime = true
        focusedDigitIndex = 0
    }

    // Reads the four boxes (missing digits default to zero) and applies the result as the new duration.
    private func commitEdit() {
        guard isEditingTime else { return }
        let values = digits.map { Int($0) ?? 0 }
        let minutes = values[0] * 10 + values[1]
        let seconds = values[2] * 10 + values[3]
        let duration = TimeInterval(minutes * 60 + seconds)
        isEditingTime = false
        focusedDigitIndex = nil
        // Defer the published engine update until SwiftUI finishes the current focus/view update pass.
        DispatchQueue.main.async {
            engine.setManualDuration(duration)
        }
    }
}

#Preview("Idle") {
    TimerDialView()
        .environmentObject(TimerEngine())
        .padding(40)
}

#Preview("Idle - Dark") {
    TimerDialView()
        .environmentObject(TimerEngine())
        .padding(40)
        .preferredColorScheme(.dark)
}

#Preview("Running") {
    TimerDialView()
        .environmentObject(TimerEngine.runningPreview())
        .padding(40)
}

#Preview("Running - Dark") {
    TimerDialView()
        .environmentObject(TimerEngine.runningPreview())
        .padding(40)
        .preferredColorScheme(.dark)
}

#Preview("Complete") {
    TimerDialView()
        .environmentObject(TimerEngine.completedPreview())
        .padding(40)
}

#Preview("Complete - Dark") {
    TimerDialView()
        .environmentObject(TimerEngine.completedPreview())
        .padding(40)
        .preferredColorScheme(.dark)
}

private extension TimerEngine {
    // Helper that spins up a running engine for preview purposes.
    static func runningPreview() -> TimerEngine {
        let engine = TimerEngine()
        engine.start()
        return engine
    }
}
