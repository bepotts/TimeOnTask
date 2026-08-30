//
//  TimeOnTaskApp.swift
//  TimeOnTask
//
//  Created by Brandon Potts on 8/16/26.
//

import SwiftUI

/// Main entry point for the TimeOnTask app.
@main
struct TimeOnTaskApp: App {
    /// Shared timer state that is injected into both the main window and menu bar UI.
    @StateObject private var engine = TimerEngine()

    /// Defines the app's visible scenes for each supported platform.
    var body: some Scene {
#if os(macOS)
        WindowGroup {
            mainTimerView
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 360, height: 440)

        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(engine)
        } label: {
            MenuBarLabel()
                .environmentObject(engine)
        }
        .menuBarExtraStyle(.window)
#else
        WindowGroup {
            mainTimerView
        }
#endif
    }

    /// Shared root view used by every platform-specific scene.
    private var mainTimerView: some View {
        ContentView()
            .environmentObject(engine)
    }
}
