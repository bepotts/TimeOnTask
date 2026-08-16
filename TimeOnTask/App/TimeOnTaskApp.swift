//
//  TimeOnTaskApp.swift
//  TimeOnTask
//
//  Created by Brandon Potts on 8/16/26.
//

import SwiftUI

// Main entry point for app
@main
struct TimeOnTaskApp: App {
    // Shared timer state that is injected into both the main window and menu bar UI.
    @StateObject private var engine = TimerEngine()

    // Defines the app's visible scenes: the main window and the menu bar extra.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
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
    }
}
