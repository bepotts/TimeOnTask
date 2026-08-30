//
//  MacTimerView.swift
//  TimeOnTask
//
//  Created by Brandon Potts on 8/16/26.
//

import SwiftUI

#if os(macOS)
struct MacTimerView: View {
    /// Shared timer state that drives the main window display and actions.
    @EnvironmentObject var engine: TimerEngine
    /// Focus target used to return keyboard focus to the primary control after editing.
    @FocusState private var focusedControl: FocusedControl?

    /// Main timer window layout with session naming, dial, controls, and presets.
    var body: some View {
        VStack(spacing: 22) {
            TextField("Name this session", text: $engine.sessionLabel)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .disabled(engine.phase != .idle)
                .accessibilityIdentifier("sessionLabelField")

            TimerDialView {
                focusedControl = .primaryButton
            }

            controls

            if engine.phase == .idle {
                presetPills
            }
        }
        .padding(32)
        .frame(width: 360, height: 440)
        .onAppear {
            DispatchQueue.main.async {
                focusedControl = .primaryButton
            }
        }
        .onChange(of: engine.phase) { _, phase in
            guard phase == .complete else { return }
            DispatchQueue.main.async {
                focusedControl = .primaryButton
            }
        }
    }

    /// Start, pause, stop, or restart controls for the current timer phase.
    @ViewBuilder
    private var controls: some View {
        switch engine.phase {
        case .idle:
            Button {
                engine.start()
                focusedControl = .primaryButton
            } label: {
                Image(systemName: "play.fill")
            }
            .buttonStyle(EmberRoundButtonStyle(filled: true))
            .focused($focusedControl, equals: .primaryButton)
            .accessibilityIdentifier("startTimerButton")
            .onKeyPress(.return) {
                performFocusedAction(engine.start, refocusing: .primaryButton)
                return .handled
            }

        case .running:
            HStack(spacing: 18) {
                Button {
                    engine.pause()
                } label: {
                    Image(systemName: "pause.fill")
                }
                .buttonStyle(EmberRoundButtonStyle(filled: false))
                .focused($focusedControl, equals: .primaryButton)
                .accessibilityIdentifier("pauseTimerButton")
                .onKeyPress(.return) {
                    performFocusedAction(engine.pause, refocusing: .primaryButton)
                    return .handled
                }

                Button("Stop") {
                    engine.stop()
                    focusedControl = .primaryButton
                }
                .buttonStyle(EmberTextButtonStyle())
                .focused($focusedControl, equals: .stopButton)
                .accessibilityIdentifier("stopTimerButton")
                .onKeyPress(.return) {
                    performFocusedAction(engine.stop, refocusing: .primaryButton)
                    return .handled
                }
            }

        case .paused:
            HStack(spacing: 18) {
                Button {
                    engine.start()
                    focusedControl = .primaryButton
                } label: {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(EmberRoundButtonStyle(filled: true))
                .focused($focusedControl, equals: .primaryButton)
                .accessibilityIdentifier("startTimerButton")
                .onKeyPress(.return) {
                    performFocusedAction(engine.start, refocusing: .primaryButton)
                    return .handled
                }

                Button("Stop") {
                    engine.stop()
                    focusedControl = .primaryButton
                }
                .buttonStyle(EmberTextButtonStyle())
                .focused($focusedControl, equals: .stopButton)
                .accessibilityIdentifier("stopTimerButton")
                .onKeyPress(.return) {
                    performFocusedAction(engine.stop, refocusing: .primaryButton)
                    return .handled
                }
            }

        case .complete:
            Button("Start another") {
                engine.startAnother()
                focusedControl = .primaryButton
            }
            .buttonStyle(EmberTextButtonStyle())
            .focused($focusedControl, equals: .primaryButton)
            .accessibilityIdentifier("startAnotherButton")
            .onKeyPress(.return) {
                performFocusedAction(engine.startAnother, refocusing: .primaryButton)
                return .handled
            }
        }
    }

    /// Idle-only preset buttons that let the user choose a session duration.
    private var presetPills: some View {
        HStack(spacing: 8) {
            ForEach(TimerEngine.presets, id: \.self) { preset in
                Button("\(Int(preset / 60))") {
                    engine.selectPreset(preset)
                }
                .buttonStyle(EmberPillButtonStyle(active: engine.duration == preset))
                .focused($focusedControl, equals: .presetButton(preset))
                .accessibilityIdentifier("preset\(Int(preset / 60))Button")
                .onKeyPress(.return) {
                    performFocusedAction(
                        { engine.selectPreset(preset) },
                        refocusing: .presetButton(preset)
                    )
                    return .handled
                }
            }
        }
    }

    /// Performs a button action and restores focus after any resulting view update.
    ///
    /// - Parameters:
    ///   - action: The button action to run on the next main-loop pass.
    ///   - control: The focus target that should remain active after the action completes.
    private func performFocusedAction(_ action: @escaping () -> Void, refocusing control: FocusedControl) {
        DispatchQueue.main.async {
            action()
            DispatchQueue.main.async {
                focusedControl = control
            }
        }
    }
}

#Preview("Light") {
    MacTimerView()
        .environmentObject(TimerEngine())
}

#Preview("Dark") {
    MacTimerView()
        .environmentObject(TimerEngine())
        .preferredColorScheme(.dark)
}
#endif
