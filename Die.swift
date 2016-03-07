//
//  Die.swift
//
//  Created by Silvan Dähn on 07.03.16.
//  Copyright © 2016 Silvan Dähn. All rights reserved.
//

import Foundation

let newline = "\n"

/// Prints the current callstack symbols before calling exit(EXIT_FAILURE)
/// - parameter message: The error message to print as failure reason
@noreturn public func die(@autoclosure message: () -> String) {
    print(message(), newline)
    die()
}

/// Prints the current callstack symbols before calling exit(EXIT_FAILURE)
@noreturn public func die() {
    print(NSThread.callStackSymbols().joinWithSeparator(newline))
    exit(EXIT_FAILURE)
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter message: The error message to print as failure reason
/// - parameter block: The block to execute in which a throw will cause a die()
public func dieOnThrow(@autoclosure message: () -> String, @noescape block: () throws -> Void) {
    do {
        try block()
    } catch {
        die(message)
    }
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter message: The error message to print as failure reason
/// - parameter block: The block to execute in which a throw will cause a die()
/// - returns: The return value of the block is forwarded
public func dieOnThrow<T>(@autoclosure message: () -> String, @noescape block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        die(message)
    }
}