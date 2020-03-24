import Foundation

struct JsonReporter: Reporter {
    func report(results: [SchemeResult]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(results)
        let json = String(data: data, encoding: .utf8)
        print(json ?? "")
    }
}
