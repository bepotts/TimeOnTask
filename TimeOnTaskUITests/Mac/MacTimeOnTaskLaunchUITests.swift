//
//  MacTimeOnTaskLaunchUITests.swift
//  TimeOnTaskUITests
//

import XCTest

#if os(macOS)
final class MacTimeOnTaskLaunchUITests: XCTestCase {
    /// Tells XCTest to run this macOS launch screenshot test across configured UI appearances.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Prepares the macOS launch test to stop immediately after a failure.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Launches the macOS app and stores a screenshot attachment for review.
    @MainActor
    func testLaunch() throws {
        // Application handle used to launch and screenshot the app under test.
        let app = UITestApp.launch()
        // Screenshot attachment kept with the test result for launch screen review.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "macOS Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
#endif
