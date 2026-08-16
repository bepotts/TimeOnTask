//
//  MenuBarContentView.swift
//  TimeOnTask
//

import SwiftUI

struct MenuBarLabel: View {
    // Shared timer state used to decide whether the menu bar should show a countdown.
    @EnvironmentObject var engine: TimerEngine

    // Compact menu bar label with the flame icon and optional remaining time.
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            if engine.phase == .running || engine.phase == .paused {
                Text(engine.formattedRemaining)
                    .monospacedDigit()
            }
        }
    }
}

struct MenuBarContentView: View {
    // Shared timer state that powers the menu bar controls and dial.
    @EnvironmentObject var engine: TimerEngine

    // Popover content shown from the menu bar extra.
    var body: some View {
        VStack(spacing: 16) {
            TimerDialView(diameter: 140, timeFontSize: 30)

            if engine.phase == .idle {
                HStack(spacing: 6) {
                    ForEach(TimerEngine.presets, id: \.self) { preset in
                        Button("\(Int(preset / 60))") {
                            engine.selectPreset(preset)
                        }
                        .buttonStyle(EmberPillButtonStyle(active: engine.duration == preset))
                    }
                }
            }

            controls

            Divider()

            Button("Quit Ember") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(EmberTextButtonStyle())
        }
        .padding(18)
        .frame(width: 220)
    }

    @ViewBuilder
    // Menu bar version of the timer controls for the current phase.
    private var controls: some View {
        switch engine.phase {
        case .idle:
            Button {
                engine.start()
            } label: {
                Image(systemName: "play.fill")
            }
            .buttonStyle(EmberRoundButtonStyle(filled: true))

        case .running:
            HStack(spacing: 14) {
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
            HStack(spacing: 14) {
                Button {
                    engine.start()
                } label: {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(EmberRoundButtonStyle(filled: true))

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
}
