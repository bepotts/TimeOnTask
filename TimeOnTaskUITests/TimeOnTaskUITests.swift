//
//  TimeOnTaskUITests.swift
//  TimeOnTaskUITests
//
//  Created by Brandon Potts on 8/16/26.
//

import XCTest

final class TimeOnTaskUITests: XCTestCase {
    /// Application under test for the current UI test.
    private var app: XCUIApplication!

    /// Prepares each UI test to stop immediately after a failure.
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    /// Cleans up after each UI test.
    override func tearDownWithError() throws {
        app = nil
    }

    /// Verifies the default timer UI launches with expected controls.
    @MainActor
    func testDefaultTimerStateShowsReadyThirtyMinutesAndPresets() throws {
        XCTAssertTrue(app.textFields["sessionLabelField"].waitForExistence(timeout: 2))
        XCTAssertTrue(waitForTimerText("30:00"))
        XCTAssertTrue(app.staticTexts["timerStatusText"].exists)
        XCTAssertTrue(app.buttons["startTimerButton"].exists)
        XCTAssertTrue(app.buttons["preset15Button"].exists)
        XCTAssertTrue(app.buttons["preset30Button"].exists)
        XCTAssertTrue(app.buttons["preset45Button"].exists)
        XCTAssertTrue(app.buttons["preset60Button"].exists)
    }

    /// Verifies preset buttons update the visible countdown while idle.
    @MainActor
    func testPresetSelectionUpdatesVisibleCountdown() throws {
        app.buttons["preset15Button"].click()
        XCTAssertTrue(waitForTimerText("15:00"))

        app.buttons["preset60Button"].click()
        XCTAssertTrue(waitForTimerText("60:00"))
    }

    /// Verifies the main start, pause, resume, and stop controls move through the expected UI states.
    @MainActor
    func testStartPauseResumeAndStopFlow() throws {
        app.buttons["preset15Button"].click()
        app.buttons["startTimerButton"].click()

        XCTAssertTrue(app.buttons["pauseTimerButton"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["stopTimerButton"].exists)
        XCTAssertFalse(app.textFields["sessionLabelField"].isEnabled)

        app.buttons["pauseTimerButton"].click()
        XCTAssertTrue(app.buttons["startTimerButton"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["stopTimerButton"].exists)

        app.buttons["startTimerButton"].click()
        XCTAssertTrue(app.buttons["pauseTimerButton"].waitForExistence(timeout: 2))

        app.buttons["stopTimerButton"].click()
        XCTAssertTrue(waitForTimerText("15:00"))
        XCTAssertTrue(app.buttons["startTimerButton"].exists)
        XCTAssertTrue(app.textFields["sessionLabelField"].isEnabled)
    }

    /// Verifies the session label can be edited before the timer starts.
    @MainActor
    func testSessionLabelCanBeEditedWhileIdle() throws {
        // Session label field shown at the top of the main timer window.
        let field = app.textFields["sessionLabelField"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))

        field.click()
        field.typeKey("a", modifierFlags: [.command])
        field.typeKey(.delete, modifierFlags: [])
        field.typeText("Deep Work")

        XCTAssertEqual(field.value as? String, "Deep Work")
    }

    /// Measures the app launch performance using XCTest's launch metric.
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    /// Waits until the visible timer text matches an expected value.
    ///
    /// - Parameters:
    ///   - text: The expected formatted countdown text.
    /// - Returns: Whether the timer text matched before the timeout.
    private func waitForTimerText(_ text: String) -> Bool {
        // Identified timer text used when SwiftUI exposes the element with its test identifier.
        let identifiedTimerText = app.staticTexts["timerRemainingText"]
        // Visible timer text used as a fallback when macOS exposes the display by label instead.
        let visibleTimerText = app.staticTexts[text]
        return identifiedTimerText.label == text || visibleTimerText.waitForExistence(timeout: 2)
    }
}
