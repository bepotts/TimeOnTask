//
//  IOSTimeOnTaskLaunchUITests.swift
//  TimeOnTaskUITests
//

import XCTest

#if os(iOS)
final class IOSTimeOnTaskLaunchUITests: XCTestCase {
    /// Tells XCTest to run this iOS and iPadOS launch screenshot test across configured UI appearances.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Prepares the iOS and iPadOS launch test to stop immediately after a failure.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Launches the iOS or iPadOS app and stores a screenshot attachment for review.
    @MainActor
    func testLaunch() throws {
        // Application handle used to launch and screenshot the app under test.
        let app = UITestApp.launch()
        // Screenshot attachment kept with the test result for launch screen review.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "iOS Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
#endif
