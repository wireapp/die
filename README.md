## Die, μ-framework to exit swift scripts
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

### Usage

Call `die()` or `die("Oh no!")` to print the current callstack and exit with code 1  
There also is a convenience function to work with throwing functions:

```swift
let contents = dieOnThrow("Unable to get the contents URL \(someURL)") {
    let contents = try fm.contentsOfDirectoryAtURL(someURL, includingPropertiesForKeys: nil, options: [])
    // Do more stuff...
    return contents
}
```


### Installation

Add `github "daehn/die"` to your `Cartfile`
