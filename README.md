## Die, μ-framework to exit swift scripts
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

### Usage

Calling `die()` or `die("Oh no!")` prints the current callstack, the optional message and calls `exit(EXIT_FAILURE)` afterwards.  
There also are multiple convenience functions to work with throwing functions:

```swift
dieOnThrow {
    try maybeThrowingFunction(["Please", "don't", "throw"])
}
```

Or using the message parameter to supply a failure reason:

```swift
dieOnThrow("Failed to compute the answer") {
    guard someValue == 42 else { throw SomeError }
}
```

And for working with throwing functions and using the result:

```swift
let contents = dieOnThrow("Unable to get the contents of \(someURL)") {
    let contents = try fm.contentsOfDirectoryAtURL(someURL, includingPropertiesForKeys: nil, options: [])
    // Do more stuff...
    return contents
}
```

### Installation

Add `github "daehn/die"` to your `Cartfile`
