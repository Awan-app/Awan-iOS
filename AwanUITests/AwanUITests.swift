//
//  AwanUITests.swift
//  AwanUITests
//
//  Created by Me3bed on 15/07/2026.
//

import XCTest

final class AwanUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["add-task-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["scenario-overlap"].exists)

        app.buttons["add-task-button"].tap()
        let titleField = app.textFields["task-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("Editable quest")
        app.buttons["task-zone-menu"].tap()
        app.buttons["Work"].tap()
        app.buttons["save-task-button"].tap()

        var taskCard = app.descendants(matching: .any)["timeline-task-Editable quest"]
        XCTAssertTrue(taskCard.waitForExistence(timeout: 3))
        scrollUpUntilHittable(taskCard, in: app)
        taskCard.tap()

        let durationStepper = app.steppers["task-duration-stepper"]
        XCTAssertTrue(durationStepper.waitForExistence(timeout: 3))
        for _ in 0..<10 {
            durationStepper.buttons["Increment"].tap()
        }
        app.buttons["save-task-button"].tap()

        taskCard = app.descendants(matching: .any)["timeline-task-Editable quest"]
        XCTAssertTrue(taskCard.waitForExistence(timeout: 3))
        XCTAssertTrue(
            String(describing: taskCard.value).contains("12:30"),
            "Expected the reconciled session to end at 12:30"
        )

        scrollDownUntilHittable(app.buttons["add-goal-button"], in: app)

        app.buttons["add-goal-button"].tap()
        XCTAssertTrue(app.textFields["goal-name-field"].waitForExistence(timeout: 3))
        app.buttons["Close"].tap()

        scrollDownUntilHittable(app.buttons["scenario-overlap"], in: app)
        app.buttons["scenario-overlap"].tap()

        XCTAssertTrue(
            app.staticTexts["Power combo detected!"].waitForExistence(timeout: 3)
        )
        XCTAssertTrue(app.buttons["nudge-action-Separate"].exists)

        app.buttons["nudge-action-Separate"].tap()

        XCTAssertFalse(
            app.staticTexts["Power combo detected!"].waitForExistence(timeout: 2)
        )

        app.buttons["scenario-missed-chain"].tap()

        for title in ["Shift the chain", "Double up", "Make independent", "Later"] {
            let action = app.buttons["nudge-action-\(title)"]
            XCTAssertTrue(action.waitForExistence(timeout: 3))
            XCTAssertTrue(action.isHittable, "Expected \(title) to be visible without scrolling")
        }

        app.buttons["nudge-action-Later"].tap()
    }

    private func scrollUpUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<8 where !element.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }

    private func scrollDownUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<8 where !element.isHittable {
            app.swipeDown()
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
