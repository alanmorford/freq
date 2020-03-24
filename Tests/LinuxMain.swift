import XCTest

import freqTests

var tests = [XCTestCaseEntry]()
tests += freqTests.allTests()
XCTMain(tests)
