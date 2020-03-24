import Foundation

protocol Reporter {
    func report(results: [SchemeResult]) throws
}

enum ReporterOption: String, CaseIterable {
    case text, json

    var reporter: Reporter {
        switch self {
        case .text:
            return TextReporter()
        case .json:
            return JsonReporter()
        }
    }
}

