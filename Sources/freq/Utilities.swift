import Foundation

extension Freq {
    static func ensureStoragePathsExist() throws {
        try FileManager.default.createDirectory(at: schemeStoragePath, withIntermediateDirectories: true, attributes: nil)
    }
}
