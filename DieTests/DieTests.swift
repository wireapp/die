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
    var expectation: XCTestExpectation?

    // MARK: - Mocking

    @noreturn private func mockExit(status: Int32) {
        exitStatus = status
        callCount += 1
        expectation?.fulfill()
        repeat { NSThread.sleepForTimeInterval(0.1) } while (true)
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
        guard let errorMessage = printHistory.first else { return XCTFail() }
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

    func assertThatItCallsDie(shouldCall: Bool = true, line: UInt = #line , file: String = #file, block: () -> Void) {
        // when
        dispatchAndWaitForDie(timeout: 2, block: block)

        // then
        let expectedCount = shouldCall ? 1 : 0
        let expectedStatus: Int32? = shouldCall ? EXIT_FAILURE : nil
        let (countEqual, statusEqual) = (callCount == expectedCount, exitStatus == expectedStatus)
        let fail: String -> Void = { self.recordFailureWithDescription($0, inFile: file, atLine: line, expected: true) }
        if !countEqual { fail("Incorrect die callcount, \(expectedCount) is not equal to \(callCount)") }
        if !statusEqual { fail("Incorrect exit status, \(expectedStatus) is not equal to \(exitStatus)") }
    }

    func assertMessagePrinted(message: String, _ history: [[Any]]) {
        guard let print = history.first else { return XCTFail() }
        XCTAssertEqual(print.count, 2)
        XCTAssertEqual(print.first as? String, message)
        XCTAssertEqual(print.last as? String, "\n")
    }

    func dispatch(block: dispatch_block_t) {
        let queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL)
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
