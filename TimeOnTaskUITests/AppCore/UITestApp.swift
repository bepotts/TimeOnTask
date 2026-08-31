//
//  UITestApp.swift
//  TimeOnTaskUITests
//

import XCTest

enum UITestApp {
    /// Launches a fresh TimeOnTask app instance for a UI test.
    ///
    /// - Returns: The launched application under test.
    static func launch() -> XCUIApplication {
        // Application handle that XCTest binds to the configured test target.
        let app = XCUIApplication()
        app.launch()
        return app
    }

    /// Waits until the visible timer text matches an expected value.
    ///
    /// - Parameters:
    ///   - text: The expected formatted countdown text.
    ///   - app: The application under test.
    /// - Returns: Whether the timer text matched before the timeout.
    static func waitForTimerText(_ text: String, in app: XCUIApplication) -> Bool {
        // Identified timer text used when SwiftUI exposes the element with its test identifier.
        let identifiedTimerText = app.staticTexts["timerRemainingText"]
        // Visible timer text used as a fallback when the platform exposes the display by label instead.
        let visibleTimerText = app.staticTexts[text]
        return identifiedTimerText.label == text || visibleTimerText.waitForExistence(timeout: 2)
    }
}
