//
//  Die.swift
//
//  Created by Silvan Dähn on 07.03.16.
//  Copyright © 2016 Silvan Dähn. All rights reserved.
//

let newline = "\n"

/// Prints the current callstack symbols before calling exit(EXIT_FAILURE)
/// - parameter message: The error message to print as failure reason
@noreturn public func die(@autoclosure message: () -> String = String()) {
    if !message().isEmpty {
        internalPrint(message(), newline)
    }
    internalPrint(NSThread.callStackSymbols().joinWithSeparator(newline))
    internalExit(EXIT_FAILURE)
}

/// Dies if the boolean result of @c condition is @c true
public func dieIfTrue(@autoclosure condition: () -> Bool) {
    dieIfFalse(!condition())
}

/// Dies if the boolean result of @c condition is @c false
public func dieIfFalse(@autoclosure condition: () -> Bool) {
    guard condition() else { die() }
}

/// Returns the result of @c closure or dies if the result is nil
public func dieIfNil<T>(@autoclosure closure: () -> T?) -> T {
    guard let result = closure() else { die() }
    return result
}

/// Dies if the result of @c closure is not nil, useful when checking for errors
public func dieIfNotNil(@autoclosure closure: () -> Any?) {
    if let object = closure() {
        die("Object was supposed to be nil: \(object)")
    }
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter message: The error message to print as failure reason
/// - parameter block: The block to execute in which a throw will cause a die()
/// - returns: The return value of the block is forwarded
public func dieOnThrow<T>(@autoclosure message: () -> String = String(), @noescape block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        internalPrint("Error: \(error)")
        die(message)
    }
}

// MARK: - Testing

// The following varaiables provide a way to inject different behaviours for testing
var internalExit = exit
var internalPrint = _internalPrint

func _internalPrint(items: Any...) {
    print(items)
}
