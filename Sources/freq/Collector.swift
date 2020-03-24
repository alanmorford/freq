import Foundation
import XCLogParser

struct Collector {
    func run() throws {
        try Freq.ensureStoragePathsExist()

        guard let buildRoot = ProcessInfo.processInfo.environment["BUILD_ROOT"],
            let buildRootPath = URL(string: buildRoot) else {
                print("??? 1")
                return
        }

        let fileManager = FileManager.default
        let buildLogsPath = buildRootPath.appendingPathComponent("../../Logs/Build")
        let manifestPath = buildLogsPath.appendingPathComponent("LogStoreManifest.plist")

        guard fileManager.fileExists(atPath: manifestPath.path) else {
            print("??? 2")
            return
        }

        guard let manifestDict = NSDictionary(contentsOfFile: manifestPath.path) else {
            print("??? 3")
            return
        }

        let manifestEntries = try LogManifest().parse(dictionary: manifestDict, atPath: manifestPath.path)
        let entriesByScheme = manifestEntries.reduce(into: [String: [LogManifestEntry]]()) { result, entry in
            result[entry.scheme, default: []].append(entry)
        }

        try entriesByScheme.forEach { scheme, entries in
            let schemePath = Freq.schemeStoragePath.appendingPathComponent(scheme)
            try fileManager.createDirectory(at: schemePath, withIntermediateDirectories: true, attributes: nil)

            try entries
                .filter { $0.title.lowercased().hasPrefix("build") }
                .forEach {
                    let entryDestinationPath = schemePath.appendingPathComponent($0.fileName)

                    if !fileManager.fileExists(atPath: entryDestinationPath.path) {
                        let entrySourcePath = buildLogsPath.appendingPathComponent($0.fileName)
                        try fileManager.copyItem(atPath: entrySourcePath.path, toPath: entryDestinationPath.path)
                    }
                }
        }
    }
}
