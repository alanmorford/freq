import Foundation

struct TextReporter: Reporter {
    func report(results: [SchemeResult]) throws {
        let fileManager = FileManager.default
        let projectPath = fileManager.currentDirectoryPath + "/"

        results.forEach { result in
            result.results.forEach { result in
                let relativePath = result.path.path.deletingPrefix(projectPath)
                print([relativePath,
                       result.frequency,
                       result.durationMean,
                       result.durationStdev])
            }
        }
    }
}
