//
//  DieTests.swift
//  DieTests
//
//  Created by Silvan Dähn on 09.03.16.
//  Copyright © 2016 Silvan Dähn. All rights reserved.
//

import XCTest
@testable import Die

extension String: ErrorType {}

class DieTests: XCTestCase {

    var callCount = 0
    var exitStatus: Int32?
    var printHistory: [[Any]] = []
    let spinMainQueue = NSThread.sleepForTimeInterval
    var expectation: XCTestExpectation?

    // MARK: - Mocking

    @noreturn private func mockExit(status: Int32) {
        exitStatus = status
        callCount++
        expectation?.fulfill()
        repeat { NSRunLoop.currentRunLoop().run() } while (true)
    }

    func mockPrint(items: Any...) {
        printHistory.append(items)
    }

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        (callCount, exitStatus, printHistory) = (0, nil, [])
        (internalExit, internalPrint)  = (mockExit, mockPrint)
    }
    
    override func tearDown() {
        (internalExit, internalPrint) = (exit, _internalPrint)
        expectation = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testThatItCallsDie() {
        // when
        dispatchAndWaitForDie(timeout: 2, block: die)

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
    }

    func testThatItCallsExitAndPrintsTheMessageAndNewline() {
        // given
        let message = "🚫"

        // when
        dispatchAndWaitForDie(timeout: 2) { die(message) }

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(printHistory.count, 2)
        assertMessagePrinted(message, printHistory)
    }

    func testThatItCallsDieIfNotNil() {
        // when
        dispatchAndWaitForDie(timeout: 2) {
            dieIfNotNil(42)
        }

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
        assertMessagePrinted("Object was supposed to be nil: 42", printHistory)
    }

    func testThatItCallsDieIfNil() {
        // when
        dispatchAndWaitForDie(timeout: 2) {
            dieIfNil(nil)
        }

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
    }

    func testThatItDoesNotCallDieWhen_DieIfNil_isCalledWithNonNil() {
        // when
        var result: Int?
        dispatchAndWaitForDie(timeout: 2) {
            result = dieIfNil(42)
            self.expectation?.fulfill()
        }

        // then
        XCTAssertEqual(result, 42)
        XCTAssertEqual(callCount, 0)
        XCTAssertNil(exitStatus)
    }

    func testThatItCallsDieOnThrow() {
        // when
        dispatchAndWaitForDie(timeout: 2) {
            dieOnThrow {
                throw "Error"
            }
        }

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
    }

    func testThatItCallsDieAndPrintsTheMessageOnThrow() {
        // given
        let message = "🚫"

        // when
        dispatchAndWaitForDie(timeout: 2) {
            dieOnThrow(message) {
                throw "Error"
            }
        }

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
        XCTAssertEqual(printHistory.count, 3)
        let errorMessage = printHistory.first!
        XCTAssertEqual(errorMessage.first as? String, "Error: Error")
        assertMessagePrinted(message, Array(printHistory.dropFirst()))
    }

    func testThatItDoesNotCallDieIfItDoesNotThrow() {
        // given
        var solution: Int?

        // when
        dispatchAndWaitForDie(timeout: 2) {
            solution = dieOnThrow {
                self.expectation?.fulfill()
                return 42
            }
        }

        // then
        XCTAssertEqual(callCount, 0)
        XCTAssertNil(exitStatus)
        XCTAssertEqual(solution, 42)
    }

    // MARK: - Helper

    func assertMessagePrinted(message: String, _ history: [[Any]]) {
        guard let print = history.first else { return XCTFail() }
        XCTAssertEqual(print.count, 2)
        XCTAssertEqual(print.first as? String, message)
        XCTAssertEqual(print.last as? String, "\n")
    }

    func dispatch(block: dispatch_block_t) {
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async(queue, block)
    }

    func waitWithTimeout(timeout: NSTimeInterval, block: dispatch_block_t) {
        expectation = expectationWithDescription("Wait for die() to be called")
        block()
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }

    func dispatchAndWaitForDie(timeout timeout: NSTimeInterval, block: dispatch_block_t) {
        waitWithTimeout(timeout) {
            self.dispatch(block)
        }
    }
}
