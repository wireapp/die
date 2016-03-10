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
        assertThatItCallsDie { die() }

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
    }

    func testThatItCallsExitAndPrintsTheMessageAndNewline() {
        // given
        let message = "🚫"

        // when
        assertThatItCallsDie { die(message) }

        // then
        XCTAssertEqual(printHistory.count, 2)
        assertMessagePrinted(message, printHistory)
    }

    func testThatItCallsDieIfFalseIfExpressionEvalutesToFalse() {
        assertThatItCallsDie {
            dieIfFalse(false)
        }
    }

    func testThatItDoesNotCallDieIfFalseIfExpressionEvalutesToTrue() {
        assertThatItCallsDie(false) {
            dieIfFalse(true)
            self.expectation?.fulfill()
        }
    }

    func testThatItCallsDieIfTrueIfExpressionEvalutesToTrue() {
        assertThatItCallsDie {
            dieIfTrue(true)
            self.expectation?.fulfill()
        }
    }

    func testThatItDoesNotCallDieIfTrueIfExpressionEvalutesToFalse() {
        assertThatItCallsDie(false) {
            dieIfTrue(false)
            self.expectation?.fulfill()
        }
    }

    func testThatItCallsDieIfNotNil() {
        // when
        assertThatItCallsDie {
            dieIfNotNil(42)
        }

        // then
        assertMessagePrinted("Object was supposed to be nil: 42", printHistory)
    }

    func testThatItCallsDieIfNil() {
        assertThatItCallsDie {
            dieIfNil(nil)
        }
    }

    func testThatItDoesNotCallDieWhen_DieIfNil_isCalledWithNonNil() {
        // when
        var result: Int?

        assertThatItCallsDie(false) {
            result = dieIfNil(42)
            self.expectation?.fulfill()
        }

        // then
        XCTAssertEqual(result, 42)
    }

    func testThatItCallsDieOnThrow() {
        assertThatItCallsDie {
            dieOnThrow {
                throw "Error"
            }
        }
    }

    func testThatItCallsDieAndPrintsTheMessageOnThrow() {
        // given
        let message = "🚫"

        // when
        assertThatItCallsDie {
            dieOnThrow(message) {
                throw "Error"
            }
        }

        // then
        XCTAssertEqual(printHistory.count, 3)
        let errorMessage = printHistory.first!
        XCTAssertEqual(errorMessage.first as? String, "Error: Error")
        assertMessagePrinted(message, Array(printHistory.dropFirst()))
    }

    func testThatItDoesNotCallDieIfItDoesNotThrow() {
        // given
        var solution: Int?
        assertThatItCallsDie(false) {
             solution = dieOnThrow {
                self.expectation?.fulfill()
                return 42
            }
        }

        // then
        XCTAssertEqual(solution, 42)
    }

    // MARK: - Helper

    func assertThatItCallsDie(shouldCall: Bool = true, block: () -> Void) {
        // when
        dispatchAndWaitForDie(timeout: 2, block: block)

        // then
        XCTAssertEqual(callCount, shouldCall ? 1 : 0)
        XCTAssertEqual(exitStatus, shouldCall ? EXIT_FAILURE : nil)
    }

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
