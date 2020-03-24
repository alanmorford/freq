import Foundation
import XCLogParser

struct Analyzer {
    func run(excludeOptions: [String], sortOption: SortOption, reporterOption: ReporterOption) throws {
        try Freq.ensureStoragePathsExist()

        let activityParser = ActivityParser()
        let fileManager = FileManager.default

        let absoluteExcludePaths = excludeOptions.compactMap { URL(string: fileManager.currentDirectoryPath)?.appendingPathComponent($0) }

        let schemePaths = try fileManager
            .contentsOfDirectory(at: Freq.schemeStoragePath,
                                 includingPropertiesForKeys: nil,
                                 options: .skipsHiddenFiles)

        let results: [SchemeResult] = try schemePaths.map { schemePath in
            let logPaths = try fileManager
                .contentsOfDirectory(at: schemePath,
                                    includingPropertiesForKeys: nil,
                                    options: .skipsHiddenFiles)
                .filter { $0.pathExtension == "xcactivitylog" }

            let sourceFiles = try logPaths.flatMap { path -> [SourceFileCompilation] in
                let activityLog = try activityParser.parseActivityLogInURL(path, redacted: false)

                return reduce(activityLog.mainSection)
                    .filter { sourceFile in
                        let path = sourceFile.path.path
                        let isProjectFile = path.hasPrefix(fileManager.currentDirectoryPath)
                        let isExcluded = absoluteExcludePaths.contains { path.hasPrefix($0.path) }
                        return isProjectFile && !isExcluded
                    }
            }

            let sourceFilesByPath = sourceFiles.reduce([URL: [SourceFileCompilation]]()) { (result, compilation) -> [URL: [SourceFileCompilation]] in
                var mutableResult = result
                mutableResult[compilation.path, default: []].append(compilation)
                return mutableResult
            }

            let results: [SourceFileResult] = sourceFilesByPath.map { (path: URL, compilations: [SourceFileCompilation]) in
                let durations = compilations.map { $0.duration }
                return SourceFileResult(path: path,
                                        frequency: compilations.count,
                                        durationMean: durations.mean,
                                        durationStdev: durations.stdev)
            }

            let scheme = schemePath.pathComponents.last ?? ""
            let sortedResults = sortOption.sort(results: results)
            return SchemeResult(scheme: scheme, results: sortedResults)
        }

        try reporterOption.reporter.report(results: results)
    }

    // MARK: - Private

    private func reduce(_ section: IDEActivityLogSection) -> [SourceFileCompilation] {
        let signature = section.signature
        let isCompile = signature.hasPrefix("CompileSwift") || signature.hasPrefix("CompileC")
        var sourceFiles = section.subSections.flatMap { reduce($0) }

        // Ignore cached & cancelled sections, since we're only interested in source files that
        // were actaully compiled.
        if isCompile && !section.wasFetchedFromCache && !section.wasCancelled,
            let url = URL(string: section.location.documentURLString) {

            let sourceFile = SourceFileCompilation(
                path: url,
                duration: section.timeStoppedRecording - section.timeStartedRecording)
            sourceFiles.append(sourceFile)
        }

        return sourceFiles
    }
}

private extension Array where Element == Double {
    var mean: Double {
        let total = reduce(0, +)
        return total / Double(count)
    }

    var stdev: Double {
        let v = map { pow($0 - mean, 2.0) }.reduce(0, { $0 + $1 })
        return sqrt(v / Double(count))
    }
}
