//
//  ContentView.swift
//  TimeOnTask
//
//  Created by Brandon Potts on 8/16/26.
//

import SwiftUI

struct ContentView: View {
    // Shared timer state that drives the main window display and actions.
    @EnvironmentObject var engine: TimerEngine
    @FocusState private var focusedControl: FocusedControl?

    // Main timer window layout with session naming, dial, controls, and presets.
    var body: some View {
        VStack(spacing: 22) {
            TextField("Name this session", text: $engine.sessionLabel)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TimerDialView {
                focusedControl = .playButton
            }

            controls

            if engine.phase == .idle {
                presetPills
            }
        }
        .padding(32)
        .frame(width: 360, height: 440)
    }

    @ViewBuilder
    // Start, pause, stop, or restart controls for the current timer phase.
    private var controls: some View {
        switch engine.phase {
        case .idle:
            Button {
                engine.start()
            } label: {
                Image(systemName: "play.fill")
            }
            .buttonStyle(EmberRoundButtonStyle(filled: true))
            .focused($focusedControl, equals: .playButton)
            .onKeyPress(.return) {
                engine.start()
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

                Button("Stop") {
                    engine.stop()
                }
                .buttonStyle(EmberTextButtonStyle())
            }

        case .paused:
            HStack(spacing: 18) {
                Button {
                    engine.start()
                } label: {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(EmberRoundButtonStyle(filled: true))
                .focused($focusedControl, equals: .playButton)
                .onKeyPress(.return) {
                    engine.start()
                    return .handled
                }

                Button("Stop") {
                    engine.stop()
                }
                .buttonStyle(EmberTextButtonStyle())
            }

        case .complete:
            Button("Start another") {
                engine.startAnother()
            }
            .buttonStyle(EmberTextButtonStyle())
        }
    }

    // Idle-only preset buttons that let the user choose a session duration.
    private var presetPills: some View {
        HStack(spacing: 8) {
            ForEach(TimerEngine.presets, id: \.self) { preset in
                Button("\(Int(preset / 60))") {
                    engine.selectPreset(preset)
                }
                .buttonStyle(EmberPillButtonStyle(active: engine.duration == preset))
            }
        }
    }
}

#Preview("Light") {
    ContentView()
        .environmentObject(TimerEngine())
}

#Preview("Dark") {
    ContentView()
        .environmentObject(TimerEngine())
        .preferredColorScheme(.dark)
}
