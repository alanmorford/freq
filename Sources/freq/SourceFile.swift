import Foundation

struct SourceFileResult: Codable {
    let path: URL
    let frequency: Int
    let durationMean: Double
    let durationStdev: Double
}

struct SchemeResult: Codable {
    let scheme: String
    let results: [SourceFileResult]
}

struct SourceFileCompilation {
    let path: URL
    let duration: Double
}
