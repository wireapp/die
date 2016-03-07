//
//  Die.swift
//
//  Created by Silvan Dähn on 07.03.16.
//  Copyright © 2016 Silvan Dähn. All rights reserved.
//

import Foundation

let newline = "\n"

/// Prints the current callstack symbols before calling exit(EXIT_FAILURE)
/// - parameter message The error message to print as failure reason
@noreturn public func die(@autoclosure message: () -> String) {
    print(message(), newline)
    die()
}

/// Prints the current callstack symbols before calling exit(EXIT_FAILURE)
@noreturn public func die() {
    print(NSThread.callStackSymbols().joinWithSeparator(newline))
    exit(EXIT_FAILURE)
}
