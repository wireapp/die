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

    // MARK: - Mocking

    @noreturn private func mockExit(status: Int32) {
        exitStatus = status
        callCount++
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
        super.tearDown()
    }

    // MARK: - Tests

    func testThatItCallsDie() {
        // when
        dispatch(die)
        spinMainQueue(1)

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
    }

    func testThatItCallsExitAndPrintsTheMessageAndNewline() {
        // given
        let message = "🚫"

        // when
        dispatch { die(message) }
        spinMainQueue(1)

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(printHistory.count, 2)
        assertMessagePrinted(message, printHistory)
    }

    func testThatItCallsDieOnThrow() {
        // when
        dispatch {
            dieOnThrow {
                throw "Error"
            }
        }

        spinMainQueue(1)

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
    }

    func testThatItCallsDieAndPrintsTheMessageOnThrow() {
        // given
        let message = "🚫"

        // when
        dispatch {
            dieOnThrow(message) {
                throw "Error"
            }
        }

        spinMainQueue(1)

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
        XCTAssertEqual(printHistory.count, 2)
        assertMessagePrinted(message, printHistory)
    }

    func testThatItDoesNotCallDieIfItDoesNotThrow() {
        // given
        var solution: Int?

        // when
        dispatch {
            solution = dieOnThrow {
                return 42
            }
        }

        spinMainQueue(1)

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
}
