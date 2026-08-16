//
//  TimeOnTaskUITestsLaunchTests.swift
//  TimeOnTaskUITests
//
//  Created by Brandon Potts on 8/16/26.
//

import XCTest

final class TimeOnTaskUITestsLaunchTests: XCTestCase {

    // Tells XCTest to run this launch screenshot test across configured UI appearances.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        // Application handle used to launch and screenshot the app under test.
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation

        // Screenshot attachment kept with the test result for launch screen review.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
