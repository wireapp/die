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

/// Returns the result of @c closure or dies if the result is nil
public func dieIfNil<T>(@autoclosure closure: () -> T?) -> T {
    guard let result = closure() else { die() }
    return result
}

/// Dies if the result of @c closure is not nil, useful when checking for errors
public func dieIfNotNil(@autoclosure closure: () -> Any?) {
    if let object = closure() {
        die("Object was supposed to be nil: \(object) ")
    }
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter message: The error message to print as failure reason
/// - parameter block: The block to execute in which a throw will cause a die()
public func dieOnThrow(@autoclosure message: () -> String, @noescape block: () throws -> Void) {
    dieOnThrow(message, block: block)
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter message: The error message to print as failure reason
/// - parameter block: The block to execute in which a throw will cause a die()
/// - returns: The return value of the block is forwarded
public func dieOnThrow<T>(@autoclosure message: () -> String, @noescape block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        die(message() + newline + "Error: \(error)")
    }
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter block: The block to execute in which a throw will cause a die()
public func dieOnThrow(@noescape block: () throws -> Void) {
    dieOnThrow(block)
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter block: The block to execute in which a throw will cause a die()
/// - returns: The return value of the block is forwarded
public func dieOnThrow<T>(@noescape block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        die("Error: \(error)")
    }
}
